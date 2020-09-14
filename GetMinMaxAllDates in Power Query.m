// GetMinMaxAllDates
let
    AllQueries = #sections,
    RecordToTable = Record.ToTable(AllQueries[Section1]),
    FilterOutCurrentQuery = Table.SelectRows(RecordToTable, each [Name] <> "GetMinMaxAllDates" and Type.Is(Value.Type([Value]), type table) = true),
    AddTableSchemaColumn = Table.AddColumn(FilterOutCurrentQuery, "TableSchema", each try Table.Schema([Value]) otherwise null),
    ExpandTableSchema = Table.Buffer(Table.ExpandTableColumn(AddTableSchemaColumn, "TableSchema", {"Name", "Kind"}, {"Column Name", "Datatype"})),
    FilterTypes = Table.SelectRows(ExpandTableSchema, each ([Datatype] = "datetime" or [Datatype] = "date")),
    AddedMinDateColumn = Table.AddColumn(FilterTypes, "Min Date", each Date.From(List.Min(Table.Column([Value], [Column Name])))),
    AddedMaxDateColumn = Table.AddColumn(AddedMinDateColumn, "Max Date", each Date.From(List.Max(Table.Column([Value], [Column Name])))),
    FilterOutUnnecessaryColumns = Table.SelectRows(AddedMaxDateColumn, each ([Column Name] <> "BirthDate")),
    MinDate = List.Min(List.Combine({FilterOutUnnecessaryColumns[Min Date], FilterOutUnnecessaryColumns[Max Date]})),
    MaxDate = List.Max(List.Combine({FilterOutUnnecessaryColumns[Min Date], FilterOutUnnecessaryColumns[Max Date]})),
    MinMaxDates = {"Min Date = " & Text.From(MinDate), "Max Date = " & Text.From(MaxDate)}
in
        MinMaxDates