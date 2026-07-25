import { useEffect, useState } from 'react';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import Spinner from '../../components/ui/Spinner';

const tiles = [
  { key: 'totalUsers', label: 'Total businesses', icon: '🏢' },
  { key: 'proUsers', label: 'Pro subscribers', icon: '⭐' },
  { key: 'freeUsers', label: 'Free plan', icon: '🌱' },
  { key: 'newSignupsLast7Days', label: 'New signups (7d)', icon: '🆕' },
  { key: 'newContactMessages', label: 'New messages', icon: '✉️' },
];

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    api
      .get('/admin/stats')
      .then(({ data }) => {
        if (!cancelled) setStats(data.data);
      })
      .catch((err) => {
        if (!cancelled) setError(apiErrorMessage(err, 'Failed to load stats'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="neo-stack" style={{ gap: 32 }}>
      <div>
        <h1 style={{ fontSize: 26, fontWeight: 800 }}>Dashboard</h1>
        <p className="text-muted">A quick look at how Ringlead is being adopted.</p>
      </div>

      {loading && <Spinner label="Loading stats…" />}
      {error && <p className="text-danger">{error}</p>}

      {stats && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 24 }}>
          {tiles.map((tile) => (
            <NeoCard key={tile.key} className="neo-stack" style={{ gap: 12 }}>
              <div className="neo-row" style={{ justifyContent: 'space-between' }}>
                <span className="text-muted" style={{ fontSize: 14, fontWeight: 600 }}>
                  {tile.label}
                </span>
                <span style={{ fontSize: 20 }}>{tile.icon}</span>
              </div>
              <span style={{ fontSize: 34, fontWeight: 800 }}>{stats[tile.key] ?? 0}</span>
            </NeoCard>
          ))}
        </div>
      )}
    </div>
  );
}
