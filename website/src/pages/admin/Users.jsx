import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoInput from '../../components/ui/NeoInput';
import NeoButton from '../../components/ui/NeoButton';
import NeoToggle from '../../components/ui/NeoToggle';
import Spinner from '../../components/ui/Spinner';

const LIMIT = 10;

export default function Users() {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [updatingId, setUpdatingId] = useState(null);

  function handleSearchChange(value) {
    setSearch(value);
    setPage(1);
  }

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    const handle = setTimeout(() => {
      api
        .get('/admin/users', { params: { page, limit: LIMIT, search } })
        .then(({ data }) => {
          if (!cancelled) setResult(data.data);
        })
        .catch((err) => {
          if (!cancelled) setError(apiErrorMessage(err, 'Failed to load users'));
        })
        .finally(() => {
          if (!cancelled) setLoading(false);
        });
    }, 300);
    return () => {
      cancelled = true;
      clearTimeout(handle);
    };
  }, [page, search]);

  async function toggleActive(user) {
    setUpdatingId(user.id);
    try {
      const { data } = await api.patch(`/admin/users/${user.id}`, { isActive: !user.isActive });
      setResult((prev) => ({
        ...prev,
        users: prev.users.map((u) => (u.id === user.id ? data.data : u)),
      }));
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to update user'));
    } finally {
      setUpdatingId(null);
    }
  }

  async function changePlan(user, plan) {
    setUpdatingId(user.id);
    try {
      const { data } = await api.patch(`/admin/users/${user.id}`, { subscriptionPlan: plan });
      setResult((prev) => ({
        ...prev,
        users: prev.users.map((u) => (u.id === user.id ? data.data : u)),
      }));
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to update user'));
    } finally {
      setUpdatingId(null);
    }
  }

  return (
    <div className="neo-stack" style={{ gap: 24 }}>
      <div className="neo-row" style={{ justifyContent: 'space-between', flexWrap: 'wrap', gap: 16 }}>
        <div>
          <h1 style={{ fontSize: 26, fontWeight: 800 }}>Users</h1>
          <p className="text-muted">{result?.total ?? 0} registered businesses</p>
        </div>
        <div style={{ width: 280 }}>
          <NeoInput
            placeholder="Search by name or email…"
            value={search}
            onChange={(e) => handleSearchChange(e.target.value)}
          />
        </div>
      </div>

      {error && <p className="text-danger">{error}</p>}

      <NeoCard style={{ padding: 0 }}>
        {loading && !result ? (
          <Spinner label="Loading users…" />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ textAlign: 'left' }}>
                  {['Business', 'Email', 'Plan', 'Active', 'Joined', ''].map((h) => (
                    <th key={h} className="text-muted" style={{ padding: '16px 20px', fontSize: 13 }}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {result?.users?.map((user) => (
                  <tr key={user.id} style={{ borderTop: '1px solid var(--shadow-dark)' }}>
                    <td style={{ padding: '14px 20px', fontWeight: 600 }}>{user.businessName}</td>
                    <td style={{ padding: '14px 20px' }} className="text-muted">
                      {user.email}
                    </td>
                    <td style={{ padding: '14px 20px' }}>
                      <select
                        className="neo-select"
                        style={{ width: 110, padding: '6px 10px' }}
                        value={user.subscriptionPlan}
                        disabled={updatingId === user.id}
                        onChange={(e) => changePlan(user, e.target.value)}
                      >
                        <option value="free">Free</option>
                        <option value="pro">Pro</option>
                      </select>
                    </td>
                    <td style={{ padding: '14px 20px' }}>
                      <NeoToggle
                        checked={user.isActive}
                        disabled={updatingId === user.id}
                        onChange={() => toggleActive(user)}
                        label={`Toggle active for ${user.businessName}`}
                      />
                    </td>
                    <td style={{ padding: '14px 20px' }} className="text-muted">
                      {new Date(user.createdAt).toLocaleDateString()}
                    </td>
                    <td style={{ padding: '14px 20px' }}>
                      <Link to={`/admin/users/${user.id}`}>
                        <NeoButton size="sm">View</NeoButton>
                      </Link>
                    </td>
                  </tr>
                ))}
                {result && result.users.length === 0 && (
                  <tr>
                    <td colSpan={6} style={{ padding: 32, textAlign: 'center' }} className="text-muted">
                      No users found.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}
      </NeoCard>

      {result && result.totalPages > 1 && (
        <div className="neo-row" style={{ justifyContent: 'center', gap: 12 }}>
          <NeoButton size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
            Previous
          </NeoButton>
          <span className="text-muted">
            Page {result.page} of {result.totalPages}
          </span>
          <NeoButton size="sm" disabled={page >= result.totalPages} onClick={() => setPage((p) => p + 1)}>
            Next
          </NeoButton>
        </div>
      )}
    </div>
  );
}
