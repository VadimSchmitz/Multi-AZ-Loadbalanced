import { Pool } from "pg";

let conn: Pool | undefined;

if (!conn) {
  console.log(
    "Connecting to database..." +
      process.env.PGSQL_HOST +
      " " +
      process.env.PGSQL_PORT
  );

  conn = new Pool({
    user: process.env.PGSQL_USER,
    password: process.env.PGSQL_PASSWORD,
    host: process.env.PGSQL_HOST,
    port: parseInt(process.env.PGSQL_PORT || "5432"),
    database: process.env.PGSQL_DATABASE,
  });
}

export default conn;
