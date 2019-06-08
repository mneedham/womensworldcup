call apoc.load.json("file:///tournaments.json")
YIELD value
MERGE (tourn:Tournament {year: value.year})
SET tourn.shortName = value.shortName
FOREACH(team in value.teams |
  MERGE (t:Team {id: team.id}) SET t.name = team.team
  MERGE (t)-[:PARTICIPATED_IN]->(tourn));


call apoc.load.json("file:///squads.json")
YIELD value
MATCH (team:Team {id: value.teamId})
MATCH (tourn:Tournament {shortName: value.shortName})
MERGE (squad:Squad {id: team.name + " in " + tourn.year})
MERGE (team)-[:NAMED]->(squad)
MERGE (squad)-[:FOR]->(tourn)
WITH *
UNWIND value.players AS player
MERGE (p:Player {id: player.id})
SET p.name = player.name, p.dob = CASE WHEN player.dob = "" THEN null ELSE datetime(player.dob) END
MERGE (p)-[:IN_SQUAD]->(squad)
