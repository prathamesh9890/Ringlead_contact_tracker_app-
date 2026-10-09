import { useState } from 'react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import NeoInput, { NeoField } from '../../components/ui/NeoInput';

export default function Login() {
  const { login, isAdmin } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (isAdmin) {
    return <Navigate to={location.state?.from?.pathname || '/admin/dashboard'} replace />;
  }

  function handleChange(e) {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      await login(form.email, form.password);
      navigate('/admin/dashboard', { replace: true });
    } catch (err) {
      setError(err.message || apiErrorMessage(err, 'Login failed'));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div
      className="container"
      style={{ minHeight: '100%', display: 'grid', placeItems: 'center', paddingTop: 40, paddingBottom: 40 }}
    >
      <NeoCard style={{ width: '100%', maxWidth: 400 }}>
        <div className="neo-stack" style={{ gap: 24 }}>
          <div className="neo-stack" style={{ gap: 4, textAlign: 'center', alignItems: 'center' }}>
            <div className="icon-bubble float" style={{ background: 'var(--tint-pink)', marginBottom: 12 }}>
              📞
            </div>
            <h1 style={{ fontSize: 26, fontWeight: 900 }}>
              Ring<span className="text-gradient">lead</span> Admin
            </h1>
            <p className="text-muted" style={{ fontSize: 14 }}>Welcome back! Sign in with your admin account 👋</p>
          </div>

          <form className="neo-stack" style={{ gap: 18 }} onSubmit={handleSubmit}>
            <NeoField label="Email">
              <NeoInput
                type="email"
                name="email"
                value={form.email}
                onChange={handleChange}
                placeholder="admin@ringlead.com"
                autoComplete="username"
                required
              />
            </NeoField>
            <NeoField label="Password">
              <NeoInput
                type="password"
                name="password"
                value={form.password}
                onChange={handleChange}
                placeholder="••••••••"
                autoComplete="current-password"
                required
              />
            </NeoField>

            {error && <p className="text-danger" style={{ fontSize: 14, margin: 0 }}>{error}</p>}

            <NeoButton type="submit" variant="primary" disabled={submitting} style={{ justifyContent: 'center' }}>
              {submitting ? 'Signing in…' : 'Sign in'}
            </NeoButton>
          </form>
        </div>
      </NeoCard>
    </div>
  );
}
