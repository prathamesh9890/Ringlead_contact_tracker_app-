import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import api, { clearTokens, setTokens } from '../api/client';

const AuthContext = createContext(null);

function loadStoredUser() {
  try {
    const raw = localStorage.getItem('ringlead_user');
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(loadStoredUser);
  const [initializing, setInitializing] = useState(true);

  useEffect(() => {
    setInitializing(false);
  }, []);

  async function login(email, password) {
    const { data } = await api.post('/auth/login', { email, password });
    const { user: loggedInUser, accessToken, refreshToken } = data.data;

    if (loggedInUser.role !== 'admin') {
      throw new Error('This account does not have admin access.');
    }

    setTokens(accessToken, refreshToken);
    localStorage.setItem('ringlead_user', JSON.stringify(loggedInUser));
    setUser(loggedInUser);
    return loggedInUser;
  }

  async function logout() {
    const refreshToken = localStorage.getItem('ringlead_refresh_token');
    try {
      await api.post('/auth/logout', { refreshToken });
    } catch {
      // best-effort — clear local state regardless
    }
    clearTokens();
    setUser(null);
  }

  const value = useMemo(
    () => ({
      user,
      isAdmin: user?.role === 'admin',
      isAuthenticated: Boolean(user),
      initializing,
      login,
      logout,
    }),
    [user, initializing],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider');
  return ctx;
}
