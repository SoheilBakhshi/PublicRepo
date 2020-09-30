// fnODataFeedAnalyser
(ODataFeed as text) => 
%   let
    Source = OData.Feed(ODataFeed),
    SourceToTable = Table.RenameColumns(
					        Table.DemoteHeaders(Table.FromValue(Source)), 
					        {{"Column1", "Name"}, {"Column2", "Data"}}
					      ),
    FilterTables = Table.SelectRows(
					        SourceToTable, 
					        each Type.Is(Value.Type([Data]), Table.Type) = true
					      ),
    SchemaAdded = Table.AddColumn(FilterTables, "Schema", each Table.Schema([Data])),
    TableColumnCountAdded = Table.AddColumn(
							        SchemaAdded, 
							        "Table Column Count", 
							        each Table.ColumnCount([Data]), 
							        Int64.Type
							      ),
    TableCountRowsAdded = Table.AddColumn(
							        TableColumnCountAdded, 
							        "Table Row Count", 
							        each Table.RowCount([Data]), 
							        Int64.Type
							      ),
    NumberOfRelatedTablesAdded = Table.AddColumn(
								        TableCountRowsAdded, 
								        "Number of Related Tables", 
								        each List.Count(Table.ColumnsOfType([Data], {Table.Type}))
								      ),
    ListOfRelatedTables = Table.AddColumn(
							        NumberOfRelatedTablesAdded, 
							        "List of Related Tables", 
							        each 
							          if [Number of Related Tables] = 0 then 
							            null
							          else 
							            Table.ColumnsOfType([Data], {Table.Type}), 
							        List.Type
							      ),
    NumberOfTextColumnsAdded = Table.AddColumn(
							        ListOfRelatedTables, 
							        "Number of Text Columns", 
							        each List.Count(Table.SelectRows([Schema], each Text.Contains([Kind], "text"))[Name]), 
							        Int64.Type
							      ),
    ListOfTextColunmsAdded = Table.AddColumn(
							        NumberOfTextColumnsAdded, 
							        "List of Text Columns", 
							        each 
							          if [Number of Text Columns] = 0 then 
							            null
							          else 
							            Table.SelectRows([Schema], each Text.Contains([Kind], "text"))[Name]
							      ),
    NumberOfNumericColumnsAdded = Table.AddColumn(
								        ListOfTextColunmsAdded, 
								        "Number of Numeric Columns", 
								        each List.Count(Table.SelectRows([Schema], each Text.Contains([Kind], "number"))[Name]), 
								        Int64.Type
								      ),
    ListOfNumericColunmsAdded = Table.AddColumn(
								        NumberOfNumericColumnsAdded, 
								        "List of Numeric Columns", 
								        each 
								          if [Number of Numeric Columns] = 0 then 
								            null
								          else 
								            Table.SelectRows([Schema], each Text.Contains([Kind], "number"))[Name]
								      ),
    NumberOfDecimalColumnsAdded = Table.AddColumn(
								        ListOfNumericColunmsAdded, 
								        "Number of Decimal Columns", 
								        each List.Count(
								            Table.SelectRows([Schema], each Text.Contains([TypeName], "Decimal.Type"))[Name]
								          ), 
								        Int64.Type
								      ),
    ListOfDcimalColunmsAdded = Table.AddColumn(
								        NumberOfDecimalColumnsAdded, 
								        "List of Decimal Columns", 
								        each 
								          if [Number of Decimal Columns] = 0 then 
								            null
								          else 
								            Table.SelectRows([Schema], each Text.Contains([TypeName], "Decimal.Type"))[Name]
								      ),
    #"Removed Other Columns" = Table.SelectColumns(
									        ListOfDcimalColunmsAdded, 
									        {
									          "Name", 
									          "Table Column Count", 
									          "Table Row Count", 
									          "Number of Related Tables", 
									          "List of Related Tables", 
									          "Number of Text Columns", 
									          "List of Text Columns", 
									          "Number of Numeric Columns", 
									          "List of Numeric Columns", 
									          "Number of Decimal Columns", 
									          "List of Decimal Columns"
									        }
									      )
  in
    #"Removed Other Columns" 
