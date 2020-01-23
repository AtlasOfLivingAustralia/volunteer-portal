
UPDATE achievement_description
SET search_query = replace (search_query, '"fullyTranscribedBy"', '"transcriptions.fullyTranscribedBy"')
WHERE search_query ~* '"fullyTranscribedBy"';


update achievement_description
SET search_query = replace (search_query, '''dateFullyTranscribed''', '''transcriptions.dateFullyTranscribed''')
where search_query ~* '''dateFullyTranscribed''';