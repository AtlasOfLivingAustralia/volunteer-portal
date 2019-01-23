package au.org.ala.volunteer

enum FieldDefinitionType {
    NameRegex,
    Literal,
    Sequence,
    NamePattern,
    DataFileColumn,
    SequenceGroupId

    @Override
    String toString() {
        return super.toString()
    }
}
