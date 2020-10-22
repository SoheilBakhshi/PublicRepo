//fnRenameColumnsFromRefQuery
(ColumnName as text) as text =>
let
    Source = 
        if (
            List.Contains(
                Record.FieldNames(#sections[Section1]), 
                "Column Names Mapping"
                ) 
             ) = true 
        then #"Column Names Mapping" 
        else null,
    ColumnNewName = 
        try 
            if List.Contains(Source[Column Name], ColumnName) = true 
            then 
                if Text.Trim(Table.SelectRows(Source, each ([Column Name] = ColumnName)){0}[Description]) = "" 
                then ColumnName 
                else Table.SelectRows(Source, each ([Column Name] = ColumnName)){0}[Description] 
            else Source 
        otherwise ColumnName
in
    ColumnNewName
