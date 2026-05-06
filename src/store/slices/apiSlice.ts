import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import { API_ENDPOINT_URL } from "src/constant";

export const tmdbApi = createApi({
  reducerPath: "tmdbApi",
  baseQuery: fetchBaseQuery({ baseUrl: API_ENDPOINT_URL }),
  endpoints: (_build) => ({}),
});
