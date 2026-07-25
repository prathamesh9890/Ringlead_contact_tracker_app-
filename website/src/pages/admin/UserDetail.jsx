import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import NeoBadge from '../../components/ui/NeoBadge';
import NeoToggle from '../../components/ui/NeoToggle';
import { NeoSelect } from '../../components/ui/NeoInput';
import Spinner from '../../components/ui/Spinner';

export default function UserDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    let cancelled = false;
    api
      .get(`/admin/users/${id}`)
      .then(({ data }) => {
        if (!cancelled) setUser(data.data);
      })
      .catch((err) => {
        if (!cancelled) setError(apiErrorMessage(err, 'Failed to load user'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [id]);

  async function saveChanges(patch) {
    setSaving(true);
    setSaved(false);
    try {
      const { data } = await api.patch(`/admin/users/${id}`, patch);
      setUser(data.data);
      setSaved(true);
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to update user'));
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <Spinner label="Loading user…" />;
  if (error && !user) {
    return (
      <div className="neo-stack" style={{ gap: 16 }}>
        <p className="text-danger">{error}</p>
        <Link to="/admin/users">
          <NeoButton size="sm">Back to users</NeoButton>
        </Link>
      </div>
    );
  }

  return (
    <div className="neo-stack" style={{ gap: 24, maxWidth: 640 }}>
      <div className="neo-row" style={{ justifyContent: 'space-between' }}>
        <div>
          <Link to="/admin/users" className="text-muted" style={{ fontSize: 14 }}>
            ← Back to users
          </Link>
          <h1 style={{ fontSize: 26, fontWeight: 800, marginTop: 8 }}>{user.businessName}</h1>
        </div>
        <NeoBadge variant={user.isActive ? 'active' : 'inactive'}>
          {user.isActive ? 'Active' : 'Suspended'}
        </NeoBadge>
      </div>

      <NeoCard className="neo-stack" style={{ gap: 20 }}>
        <div>
          <div className="text-muted" style={{ fontSize: 13 }}>Email</div>
          <div style={{ fontWeight: 600 }}>{user.email}</div>
        </div>
        <div>
          <div className="text-muted" style={{ fontSize: 13 }}>Phone</div>
          <div style={{ fontWeight: 600 }}>{user.phone || '—'}</div>
        </div>
        <div>
          <div className="text-muted" style={{ fontSize: 13 }}>Joined</div>
          <div style={{ fontWeight: 600 }}>{new Date(user.createdAt).toLocaleString()}</div>
        </div>

        <hr style={{ border: 'none', borderTop: '1px solid var(--shadow-dark)' }} />

        <div className="neo-row" style={{ justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontWeight: 700 }}>Subscription plan</div>
            <div className="text-muted" style={{ fontSize: 13 }}>Controls feature access for this account</div>
          </div>
          <NeoSelect
            style={{ width: 130 }}
            value={user.subscriptionPlan}
            disabled={saving}
            onChange={(e) => saveChanges({ subscriptionPlan: e.target.value })}
          >
            <option value="free">Free</option>
            <option value="pro">Pro</option>
          </NeoSelect>
        </div>

        <div className="neo-row" style={{ justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontWeight: 700 }}>Account active</div>
            <div className="text-muted" style={{ fontSize: 13 }}>Suspending blocks this account from signing in</div>
          </div>
          <NeoToggle
            checked={user.isActive}
            disabled={saving}
            onChange={(next) => saveChanges({ isActive: next })}
            label="Toggle account active"
          />
        </div>

        {error && <p className="text-danger">{error}</p>}
        {saved && !saving && <p style={{ color: 'var(--accent-2)', fontSize: 14 }}>Saved.</p>}
      </NeoCard>
    </div>
  );
}
