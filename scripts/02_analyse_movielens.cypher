// TP Neo4j - MovieLens | AJC Formation | 24 novembre 2026
// Requêtes d'analyse commentées. Import préalable : 01_import_movielens.cypher.
// Exécuter les requêtes séparément.

// Q1 - Nombre d'utilisateurs
MATCH (u:User) RETURN count(u) AS Nombre_utilisateurs;
// Q2 - Age et sexe de l'utilisateur 1
MATCH (u:User {id: 1}) RETURN u.age AS Age, u.sex AS Sexe;
// Q3.1 - Femmes artistes
MATCH (u:User) WHERE u.sex = 'F' AND u.occupation = 'artist'
RETURN u.id AS Identifiant, u.age AS Age, u.sex AS Sexe, u.occupation AS Profession;
// Q3.2 - Femmes artistes ou auteurs
MATCH (u:User) WHERE u.sex = 'F' AND (u.occupation = 'artist' OR u.occupation = 'writer')
RETURN u.id AS Identifiant, u.age AS Age, u.sex AS Sexe, u.occupation AS Profession ORDER BY Identifiant;
// Q4 - Age moyen des étudiants
MATCH (u:User) WHERE u.occupation = 'student' RETURN avg(u.age) AS Age_moyen_etudiants;
// Q5 - Age moyen par profession
MATCH (u:User) RETURN u.occupation AS Profession, round(avg(u.age), 2) AS Age_moyen ORDER BY Age_moyen DESC;
// Q6.1 - Effectif par profession
MATCH (u:User) RETURN u.occupation AS Profession, count(u) AS Nombre_utilisateurs ORDER BY Nombre_utilisateurs DESC;
// Q6.2 - Top 5 professions
MATCH (u:User) RETURN u.occupation AS Profession, count(u) AS Nombre_utilisateurs ORDER BY Nombre_utilisateurs DESC LIMIT 5;
// Q7 - Nombre de professions
MATCH (u:User) RETURN count(DISTINCT u.occupation) AS Nombre_occupations;
// Q8 - Professions dont l'âge moyen dépasse 30 ans
MATCH (u:User) WITH u.occupation AS Profession, avg(u.age) AS Age_moyen WHERE Age_moyen > 30 RETURN count(Profession) AS Nombre_occupations;
// Q9 - Films de 1995
MATCH (m:Movie) WHERE m.title =~ '.*\\(1995\\)$' RETURN m.id AS Identifiant, m.title AS Titre ORDER BY Titre ASC;
// Q10 - Nombre de notes
MATCH ()-[r:RATED]->() RETURN count(r) AS Nombre_notes;
// Q11 - Graphe des films notés par l'utilisateur 1
MATCH (u:User {id: 1})-[r:RATED]->(m:Movie) RETURN u, r, m;
// Q12 - Graphe des utilisateurs ayant noté Braveheart
MATCH (u:User)-[r:RATED]->(m:Movie) WHERE m.title = 'Braveheart (1995)' RETURN u, r, m;
// Q13 - Top 5 genres
MATCH (m:Movie)-[:IN_GENRE]->(g:Genre) RETURN g.name AS Genre, count(DISTINCT m) AS Nombre_films ORDER BY Nombre_films DESC LIMIT 5;
// Q14 - Top 10 films les plus notés
MATCH (u:User)-[r:RATED]->(m:Movie) RETURN m.title AS Titre, count(r) AS Nombre_notes ORDER BY Nombre_notes DESC LIMIT 10;
// Q15 - Films ayant reçu au moins une note de 1
MATCH (u:User)-[r:RATED]->(m:Movie) WHERE r.rating = 1 RETURN count(DISTINCT m) AS Nombre_films;
// Q16 - Notes de 1 et utilisateurs
MATCH (u:User)-[r:RATED]->(m:Movie) WHERE r.rating = 1
RETURN m.title AS Titre, count(r) AS Nombre_notes_1, collect(DISTINCT u.id) AS Liste_utilisateurs ORDER BY Nombre_notes_1 DESC;
// Q17 - Moyenne supérieure à 4
MATCH (u:User)-[r:RATED]->(m:Movie) WITH m, avg(r.rating) AS Note_moyenne WHERE Note_moyenne > 4
RETURN m.title AS Titre, round(Note_moyenne, 2) AS Note_moyenne ORDER BY Note_moyenne DESC;
// Q18 - Moyenne égale à 5
MATCH (u:User)-[r:RATED]->(m:Movie) WITH m, avg(r.rating) AS Note_moyenne WHERE Note_moyenne = 5
RETURN m.title AS Titre, Note_moyenne ORDER BY Titre ASC;
// Q19 - Amis et amis des amis
MATCH (u:User {id: 1})-[:FRIENDS*1..2]->(a:User) WHERE a.id <> 1
RETURN DISTINCT a.id AS Identifiant, a.age AS Age, a.sex AS Sexe, a.occupation AS Profession ORDER BY Identifiant ASC;
// Q20 - Degré de séparation
MATCH (u:User {id: 1}), (a:User) WHERE a.id <> 1
MATCH p = shortestPath((u)-[:FRIENDS*1..2]->(a))
RETURN a.id AS Identifiant, a.age AS Age, a.sex AS Sexe, a.occupation AS Profession, length(p) AS Degre_separation ORDER BY Degre_separation ASC, Identifiant ASC;
// Q21 - Maximum d'amis communs
MATCH (u:User {id: 1})-[:FRIENDS]->(a:User)<-[:FRIENDS]-(v:User) WHERE v.id <> 1
RETURN v.id AS Identifiant, count(DISTINCT a) AS Nombre_amis_communs, collect(DISTINCT a.id) AS Liste_amis_communs ORDER BY Nombre_amis_communs DESC, Identifiant ASC LIMIT 1;
// Q22 - Non-ami ayant le plus d'amis communs
MATCH (u:User {id: 1})-[:FRIENDS]->(a:User)<-[:FRIENDS]-(v:User) WHERE v.id <> 1
AND NOT EXISTS { MATCH (u)-[:FRIENDS]-(v) }
RETURN v.id AS Identifiant, count(DISTINCT a) AS Nombre_amis_communs, collect(DISTINCT a.id) AS Liste_amis_communs ORDER BY Nombre_amis_communs DESC, Identifiant ASC LIMIT 1;
// Q23 - Maximum de films notés en commun
MATCH (u:User {id: 1})-[:RATED]->(m:Movie)<-[:RATED]-(v:User) WHERE v.id <> 1
RETURN v.id AS Identifiant, count(DISTINCT m) AS Nombre_films_communs ORDER BY Nombre_films_communs DESC, Identifiant ASC LIMIT 1;
