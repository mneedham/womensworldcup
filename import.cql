call apoc.load.json("file:///tournaments.json")
YIELD value
MERGE (tourn:Tournament {year: value.year})
SET tourn.shortName = value.shortName, tourn.name = value.name
FOREACH(team in value.teams |
  MERGE (t:Team {id: team.id}) SET t.name = team.team
  MERGE (t)-[:PARTICIPATED_IN]->(tourn))


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
MERGE (p)-[:IN_SQUAD]->(squad);


call apoc.load.json("file:///matches.json")
YIELD value
MATCH (tourn:Tournament {name: value.SeasonShortName[0].Description})
MATCH (home:Team {id: value.HomeTeam.IdTeam})
MATCH (away:Team {id: value.AwayTeam.IdTeam})
MERGE (match:Match {id:value.IdMatch})
SET match.stage = value.StageName[0].Description
MERGE (match)-[:IN_TOURNAMENT]->(tourn)
MERGE (home)-[homePlayed:PLAYED_IN]->(match)
SET homePlayed.score = value.HomeTeam.Score, homePlayed.penaltyScore = value.HomeTeamPenaltyScore
MERGE (away)-[awayPlayed:PLAYED_IN]->(match)
SET awayPlayed.score = value.AwayTeam.Score, awayPlayed.penaltyScore = value.AwayTeamPenaltyScore
