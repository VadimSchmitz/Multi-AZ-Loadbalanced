import conn from "../../../utils/db";
import type { NextApiRequest, NextApiResponse } from "next";

export default async (req: NextApiRequest, res: NextApiResponse) => {
  if (!conn) {
    res.status(500).json({ error: "No connection to database" });
    return;
  }

  try {
    const query: string = "SELECT * FROM ip.visitor_ip;";
    const result = await conn.query(query);

    res.status(200).json(result.rows);
  } catch (err) {
    console.log(err);

    res.status(500).json({ error: "Error getting entries from the database" });
  }
};
