using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.SqlServer.Server;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;

// From http://www.sqllion.com/2010/12/pattern-matching-regex-in-t-sql/
// And  https://www.simple-talk.com/sql/t-sql-programming/clr-assembly-regex-functions-for-sql-server-by-example/

public class RegularExpressionFunctions
  {
      [Microsoft.SqlServer.Server.SqlProcedure]
      [Microsoft.SqlServer.Server.SqlFunction(IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.Read)]
      public static SqlBoolean RegExIsMatch(SqlString pattern, SqlString input, SqlInt32 options)
      {
          try
          {
            if (input.IsNull || pattern.IsNull) {
                return SqlBoolean.False;
            }
            RegexOptions regExOption = (RegexOptions) (int) options;
            return Regex.IsMatch(input.Value, pattern.Value, regExOption);
          }
          catch (Exception ex)
          {
              SqlContext.Pipe.Send("Error searching Pattern " + ex.Message);
              return SqlBoolean.False;
          }
      }
}
