CALL apoc.load.json("file:///tournaments.json")
YIELD value
MERGE (tourn:Tournament {year: value.year})
SET tourn.shortName = value.shortName, tourn.name = value.name
FOREACH(team in value.teams |
  MERGE (t:Team {id: team.id}) SET t.name = team.team
  MERGE (t)-[:PARTICIPATED_IN]->(tourn));


CALL apoc.load.json("file:///squads.json")
YIELD value
MATCH (team:Team {id: value.teamId})
MATCH (tourn:Tournament {shortName: value.shortName})
MERGE (squad:Squad {id: team.name + " in " + tourn.year})
MERGE (team)-[:NAMED]->(squad)
MERGE (squad)-[:FOR]->(tourn)
WITH *
UNWIND value.players AS player
MERGE (p:Person {id: player.id})
SET p.name = player.name, p.dob = CASE WHEN player.dob = "" THEN null ELSE date(player.dob) END
WITH *
CALL apoc.do.when(player.role = "0", 'SET p:Coach MERGE (p)-[:COACH_FOR]->(squad)', 'SET p:Player MERGE (p)-[:IN_SQUAD]->(squad)', {p:p, squad:squad}) YIELD value AS ignore
RETURN count(*);

CALL apoc.load.json("file:///matches.json")
YIELD value
MATCH (tourn:Tournament {name: value.SeasonShortName[0].Description})
MATCH (home:Team {id: value.HomeTeam.IdTeam})
MATCH (away:Team {id: value.AwayTeam.IdTeam})
MERGE (match:Match {id:value.IdMatch})
SET match.stage = value.StageName[0].Description,
    match.date = date(apoc.date.format(datetime(value.Date).epochMillis, "ms", "yyyy-MM-dd"))
MERGE (match)-[:IN_TOURNAMENT]->(tourn)
MERGE (home)-[homePlayed:PLAYED_IN]->(match)
SET homePlayed.score = value.HomeTeam.Score, homePlayed.penaltyScore = value.HomeTeamPenaltyScore
MERGE (away)-[awayPlayed:PLAYED_IN]->(match)
SET awayPlayed.score = value.AwayTeam.Score, awayPlayed.penaltyScore = value.AwayTeamPenaltyScore

FOREACH (goal IN [v in value.HomeTeam.Goals WHERE not v.IdPlayer  is null] |
  MERGE (p:Person {id: goal.IdPlayer})
  MERGE (p)-[:SCORED_GOAL {minute: goal.Minute}]->(match)
)

FOREACH (goal IN [v in value.AwayTeam.Goals WHERE not v.IdPlayer  is null] |
  MERGE (p:Person {id: goal.IdPlayer})
  MERGE (p)-[:SCORED_GOAL {minute: goal.Minute}]->(match)
)

FOREACH (player IN [v in value.HomeTeam.Players WHERE v.Status = 1] |
  MERGE (p:Person {id: player.IdPlayer})
  MERGE (p)-[:PLAYED_IN]->(match)
)

FOREACH (player IN [v in value.AwayTeam.Players WHERE v.Status = 1] |
  MERGE (p:Person {id: player.IdPlayer})
  MERGE (p)-[:PLAYED_IN]->(match)
);

MATCH (p:Person)-[:IN_SQUAD]-()<-[:NAMED]-(team:Team)
MERGE (p)-[:REPRESENTS]->(team);
