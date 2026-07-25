import axios from 'axios';

const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const api = axios.create({ baseURL });

function getTokens() {
  return {
    accessToken: localStorage.getItem('ringlead_access_token'),
    refreshToken: localStorage.getItem('ringlead_refresh_token'),
  };
}

export function setTokens(accessToken, refreshToken) {
  if (accessToken) localStorage.setItem('ringlead_access_token', accessToken);
  if (refreshToken) localStorage.setItem('ringlead_refresh_token', refreshToken);
}

export function clearTokens() {
  localStorage.removeItem('ringlead_access_token');
  localStorage.removeItem('ringlead_refresh_token');
  localStorage.removeItem('ringlead_user');
}

api.interceptors.request.use((config) => {
  const { accessToken } = getTokens();
  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }
  return config;
});

let refreshPromise = null;

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const { config, response } = error;
    const { refreshToken } = getTokens();

    if (response?.status !== 401 || config.__isRetry || !refreshToken) {
      return Promise.reject(error);
    }

    if (!refreshPromise) {
      refreshPromise = axios
        .post(`${baseURL}/auth/refresh`, { refreshToken })
        .then(({ data }) => {
          setTokens(data.data.accessToken, data.data.refreshToken);
          return data.data.accessToken;
        })
        .catch((refreshError) => {
          clearTokens();
          throw refreshError;
        })
        .finally(() => {
          refreshPromise = null;
        });
    }

    try {
      const newAccessToken = await refreshPromise;
      config.__isRetry = true;
      config.headers.Authorization = `Bearer ${newAccessToken}`;
      return api(config);
    } catch (refreshError) {
      return Promise.reject(refreshError);
    }
  },
);

export function apiErrorMessage(error, fallback = 'Something went wrong') {
  return error?.response?.data?.message || fallback;
}

export default api;
