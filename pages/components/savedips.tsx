import { useState, useEffect } from "react";
import axios from "axios";
export default function Data(): JSX.Element {
  class Data {
    id?: number;
    ip?: string;
  }

  const [data, setData] = useState<Data[] | undefined>(undefined);
  const [statusCode, setStatusCode] = useState<number | undefined>(undefined);

  useEffect(() => {
    if (!data) {
      axios
        .get("/api/ip/list")
        .then((res) => {
          setStatusCode(res.status);
          if (res.status === 200) {
            setData(res.data);
          }
        })
        .catch((err) => {
          setStatusCode(err.response.status);
        });
    }
    fetch("/api/ip/insert").then((res) => res.json());
  }, []);

  if (statusCode === undefined) {
    return <div>Loading...</div>;
  } else if (statusCode === 200) {
    return (
      <div>
        <h1>Your IP!: {data?.[data.length - 1].ip}</h1>
        <h2>Saved IP Addresses</h2>
        <ul>
          {data?.map((item) => (
            <li key={item.id}>{item.ip}</li>
          ))}
        </ul>
      </div>
    );
  } else if (statusCode === 500) {
    return <div>Internal Server Error</div>;
  } else {
    return <div>Unknown Error</div>;
  }
}
