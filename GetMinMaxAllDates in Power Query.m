// GetMinMaxAllDates
let
    // Retrieve all queries in the current workbook
    AllQueries = #sections,
    
    // Convert the section record containing queries to a table
    RecordToTable = Record.ToTable(AllQueries[Section1]),
    
    // Filter out the current query itself and ensure the remaining items are tables
    FilterOutCurrentQuery = Table.SelectRows(RecordToTable, each [Name] <> "GetMinMaxAllDates" and Type.Is(Value.Type([Value]), type table) = true),
    
    // Add a column to include the schema of each table
    AddTableSchemaColumn = Table.AddColumn(FilterOutCurrentQuery, "TableSchema", each try Table.Schema([Value]) otherwise null),
    
    // Expand the schema column to get column names and their data types, and buffer the table to improve performance
    ExpandTableSchema = Table.Buffer(Table.ExpandTableColumn(AddTableSchemaColumn, "TableSchema", {"Name", "Kind"}, {"Column Name", "Datatype"})),
    
    // Filter rows to keep only those columns which are of type datetime or date
    FilterTypes = Table.SelectRows(ExpandTableSchema, each ([Datatype] = "datetime" or [Datatype] = "date")),
    
    // Add a column to compute the minimum date value for each date/datetime column
    AddedMinDateColumn = Table.AddColumn(FilterTypes, "Min Date", each Date.From(List.Min(Table.Column([Value], [Column Name])))),
    
    // Add a column to compute the maximum date value for each date/datetime column
    AddedMaxDateColumn = Table.AddColumn(AddedMinDateColumn, "Max Date", each Date.From(List.Max(Table.Column([Value], [Column Name])))),
    
    // Filter out unnecessary columns, e.g., BirthDate
    FilterOutUnnecessaryColumns = Table.SelectRows(AddedMaxDateColumn, each ([Column Name] <> "BirthDate")),
    
    // Find the overall minimum date from the filtered columns
    MinDate = List.Min(List.Combine({FilterOutUnnecessaryColumns[Min Date], FilterOutUnnecessaryColumns[Max Date]})),
    
    // Find the overall maximum date from the filtered columns
    MaxDate = List.Max(List.Combine({FilterOutUnnecessaryColumns[Min Date], FilterOutUnnecessaryColumns[Max Date]})),
    
    // Combine the results into a list with min and max dates as text
    MinMaxDates = {"Min Date = " & Text.From(MinDate), "Max Date = " & Text.From(MaxDate)}
in
    // Output the final list with min and max dates
    MinMaxDates
