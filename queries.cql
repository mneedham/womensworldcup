// Players who were named in the most World Cup Squads
MATCH (player:Player)-[:IN_SQUAD]->(s)<-[:NAMED]-(team), (s)-[:FOR]->(tourn)
RETURN player.name AS player, team.name, count(*) AS squads, apoc.coll.sort(collect(tourn.year)) AS years
ORDER BY squads DESC
LIMIT 10;

// World Cup Winners
MATCH path = (team2)-[t2:PLAYED_IN]-(match:Match {stage: "Final"})<-[t1:PLAYED_IN]-(team1), (match)-[:IN_TOURNAMENT]->(tourn)
WHERE id(team1) < id(team2)
RETURN tourn.name, tourn.year,  team1.name, team2.name,
       CASE WHEN t1.score = t2.score
            THEN t1.score + "-" + t2.score + " (" + t1.penaltyScore + "-" + t2.penaltyScore + ")"
            ELSE t1.score + "-" + t2.score
       END AS result,
       (CASE WHEN t1.score > t2.score
            THEN team1
            WHEN t2.score > t1.score
            THEN team2
            ELSE
             CASE WHEN t1.penaltyScore > t2.penaltyScore THEN team1 ELSE team2 END END).name AS winner
ORDER BY tourn.year;
