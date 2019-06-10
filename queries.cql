// Players who were named in the most World Cup Squads
MATCH (player:Person)-[:IN_SQUAD]->(s)<-[:NAMED]-(team), (s)-[:FOR]->(tourn)
RETURN player.name AS player, team.name, count(*) AS squads, apoc.coll.sort(collect(tourn.year)) AS years
ORDER BY squads DESC
LIMIT 10;

// World Cup Winners
MATCH path = (team2:Team)-[t2:PLAYED_IN]-(match:Match {stage: "Final"})<-[t1:PLAYED_IN]-(team1:Team), (match)-[:IN_TOURNAMENT]->(tourn)
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

// Top Scorers
match (p:Person)-[:SCORED_GOAL]->(match)-[:IN_TOURNAMENT]->(tourn), (p)-[:REPRESENTS]->(team)
return p.name, team.name AS team, count(*) AS goals, apoc.coll.sort(collect(DISTINCT tourn.year)) AS years
ORDER BY goals DESC;

// Top Scorers + Appearances
MATCH (p:Person)-[:SCORED_GOAL]->(match)-[:IN_TOURNAMENT]->(tourn), (p)-[:REPRESENTS]->(team)
WITH p, team, count(*) AS goals, apoc.coll.sort(collect(DISTINCT tourn.year)) AS years,
     size((p)-[:PLAYED_IN]->()) AS matches,
     size([(p)-[pi:PLAYED_IN]->() WHERE pi.type = "Subbed On" | pi]) AS subs
return p.name, team.name AS team, goals, years,
CASE WHEN subs > 0 THEN matches + " (" + subs + ")" ELSE toString(matches) END AS matches
ORDER BY goals DESC;

// Goals scored by Marta
match (p:Person {name: "MARTA"})-[sg:SCORED_GOAL]->(match)-[:IN_TOURNAMENT]->(tourn),
      (team)-[:PLAYED_IN]->(match)
WHERE not (p)-[:REPRESENTS]-(team)
return match.id, tourn.year, tourn.name, team.name AS opponent, count(sg) AS goals
ORDER BY tourn.year;

// Players who also coached
match (p:Person)
MATCH (p)-[:IN_SQUAD]->(s:Squad)<-[:NAMED]-(:Team)-[:PARTICIPATED_IN]->(tourn:Tournament), (s)-[:FOR]->(tourn)
WITH p, apoc.coll.sort(collect(tourn.year)) AS playerYears
MATCH (p)-[:COACH_FOR]->(s:Squad)<-[:NAMED]-(:Team)-[:PARTICIPATED_IN]->(tourn:Tournament), (s)-[:FOR]->(tourn)
RETURN p.name, apoc.coll.sort(collect(tourn.year)) AS coachYears, playerYears;


// England's Matches
MATCH path = (team:Team {name: "England"})-[t1:PLAYED_IN]->(match:Match)<-[t2:PLAYED_IN]-(opponent:Team)
WITH match, opponent, t1, t2
RETURN toString(match.date) AS date,
       match.stage, opponent.name,
       CASE WHEN t1.score = t2.score AND exists(t1.penaltyScore) AND exists(t2.penaltyScore)
            THEN t1.score + "-" + t2.score + " (" + t1.penaltyScore + "-" + t2.penaltyScore + ")"
            ELSE t1.score + "-" + t2.score
       END AS result
ORDER BY match.date

// USA's last match in each tournament
MATCH (tourn:Tournament)
MATCH (team:Team {name: "USA"})-[t1:PLAYED_IN]->(match:Match)-[:IN_TOURNAMENT]->(tourn), (opponent:Team)-[t2:PLAYED_IN]->(match)
WITH tourn, match, opponent, t1, t2
ORDER BY tourn, match.date DESC
WITH tourn, collect(match)[0] AS match, collect(t1)[0] AS t1, collect(t2)[0] AS t2, collect(opponent)[0] AS opponent
RETURN tourn.name, toString(match.date) AS date,
       match.stage, opponent.name,
       CASE WHEN t1.score = t2.score AND exists(t1.penaltyScore) AND exists(t2.penaltyScore)
            THEN t1.score + "-" + t2.score + " (" + t1.penaltyScore + "-" + t2.penaltyScore + ")"
            ELSE t1.score + "-" + t2.score
       END AS result
ORDER BY match.date
