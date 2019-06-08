// Players who were named in the most World Cup Squads
MATCH (player:Player)-[:IN_SQUAD]->(s)<-[:NAMED]-(team), (s)-[:FOR]->(tourn)
RETURN player.name AS player, team.name, count(*) AS squads, apoc.coll.sort(collect(tourn.year)) AS years
ORDER BY squads DESC
LIMIT 10
