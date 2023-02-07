import conn from "../../../utils/db";
import type { NextApiRequest, NextApiResponse } from "next";

export default async (req: NextApiRequest, res: NextApiResponse) => {
  if (!conn) {
    return res.status(500).json({ error: "No connection to database" });
  }

  const ip = req.socket.remoteAddress;

  console.log(ip);

  try {
    const query: string = "SELECT * FROM ip.visitor_ip WHERE ip = $1;";
    const result = await conn.query(query, [ip]);

    if (result.rows.length > 0) {
      return res.status(200).json({ message: "IP already in database" });
    }
  } catch (err) {
    return res
      .status(500)
      .json({ error: "Error checking if IP is already in the database" });
  }

  try {
    const query: string = "INSERT INTO ip.visitor_ip (ip) VALUES ($1);";
    const result = await conn.query(query, [ip]);

    return res.status(200).json({ result });
  } catch (err) {
    return res.status(500).json({ error: "Error inserting into database" });
  }
};
