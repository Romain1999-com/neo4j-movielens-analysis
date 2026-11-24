// Import MovieLens — adaptation du support pédagogique AJC.
// Placer les six CSV dans le dossier import de l'instance locale.
// Exécuter chaque instruction séparément en transaction implicite.
// Dans Neo4j Query, utiliser le préfixe :auto pour les imports par lots.

// 01 — Utilisateurs
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS users
CALL {
  WITH users
  MERGE (u:User {id: toInteger(users.id)})
  ON CREATE SET u.age = toInteger(users.age),
    u.sex = users.sex, u.occupation = users.occupation,
    u.zip_code = users.zip_code
} IN TRANSACTIONS OF 1000 ROWS;

// 02 — Films
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS movies
CALL {
  WITH movies
  MERGE (m:Movie {id: toInteger(movies.id)})
  ON CREATE SET m.title = movies.title, m.date = toInteger(movies.date)
} IN TRANSACTIONS OF 1000 ROWS;

// 03 — Genres
LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS genres
CALL {
  WITH genres
  MERGE (g:Genre {id: toInteger(genres.id)})
  ON CREATE SET g.name = genres.name
} IN TRANSACTIONS OF 1000 ROWS;

// 04 — Associations films / genres
LOAD CSV WITH HEADERS FROM 'file:///mov_genre.csv' AS mg
CALL {
  WITH mg
  MATCH (m:Movie {id: toInteger(mg.mov_id)})
  MATCH (g:Genre {id: toInteger(mg.genre)})
  MERGE (m)-[:IN_GENRE]->(g)
} IN TRANSACTIONS OF 1000 ROWS;

// 05 — Amitiés (CSV déjà symétrique)
LOAD CSV WITH HEADERS FROM 'file:///friends.csv' AS f
CALL {
  WITH f
  MATCH (u1:User {id: toInteger(f.user1_id)})
  MATCH (u2:User {id: toInteger(f.user2_id)})
  MERGE (u1)-[:FRIENDS]->(u2)
} IN TRANSACTIONS OF 1000 ROWS;

// 06 — Évaluations
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS r
CALL {
  WITH r
  MATCH (u:User {id: toInteger(r.user_id)})
  MATCH (m:Movie {id: toInteger(r.mov_id)})
  MERGE (u)-[x:RATED]->(m)
  ON CREATE SET x.rating = toInteger(r.rating),
    x.timestamp = toInteger(r.timestamp)
} IN TRANSACTIONS OF 1000 ROWS;

// 07 — Vérification des effectifs
MATCH (u:User) WITH count(u) AS users
MATCH (m:Movie) WITH users, count(m) AS movies
MATCH (g:Genre) WITH users, movies, count(g) AS genres
MATCH ()-[f:FRIENDS]->() WITH users, movies, genres, count(f) AS friendships
MATCH ()-[r:RATED]->() WITH users, movies, genres, friendships, count(r) AS ratings
MATCH ()-[ig:IN_GENRE]->()
RETURN users, movies, genres, friendships, ratings, count(ig) AS inGenre;

// 08 — Contrôle des références des évaluations
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS r
RETURN count(*) AS total,
  sum(CASE WHEN NOT EXISTS { (:User {id: toInteger(r.user_id)}) } THEN 1 ELSE 0 END) AS usersManquants,
  sum(CASE WHEN NOT EXISTS { (:Movie {id: toInteger(r.mov_id)}) } THEN 1 ELSE 0 END) AS moviesManquants;
