CREATE EXTENSION "uuid-ossp";

update task set transcribeduuid = uuid_generate_v4() where transcribeduuid is null and fully_transcribed_by is not null;
update task set validateduuid = uuid_generate_v4() where validateduuid is null and fully_validated_by is not null;

DROP EXTENSION "uuid-ossp";