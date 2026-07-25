import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import NeoBadge from '../../components/ui/NeoBadge';
import { NeoSelect } from '../../components/ui/NeoInput';
import Spinner from '../../components/ui/Spinner';

const LIMIT = 10;

export default function Messages() {
  const [status, setStatus] = useState('');
  const [page, setPage] = useState(1);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [updatingId, setUpdatingId] = useState(null);

  function handleStatusChange(value) {
    setStatus(value);
    setPage(1);
  }

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    api
      .get('/admin/contacts', { params: { page, limit: LIMIT, status: status || undefined } })
      .then(({ data }) => {
        if (!cancelled) setResult(data.data);
      })
      .catch((err) => {
        if (!cancelled) setError(apiErrorMessage(err, 'Failed to load messages'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [page, status]);

  async function toggleResolved(message) {
    setUpdatingId(message.id);
    try {
      const nextStatus = message.status === 'new' ? 'resolved' : 'new';
      const { data } = await api.patch(`/admin/contacts/${message.id}`, { status: nextStatus });
      setResult((prev) => ({
        ...prev,
        messages: prev.messages.map((m) => (m.id === message.id ? data.data : m)),
      }));
    } catch (err) {
      setError(apiErrorMessage(err, 'Failed to update message'));
    } finally {
      setUpdatingId(null);
    }
  }

  return (
    <div className="neo-stack" style={{ gap: 24 }}>
      <div className="neo-row" style={{ justifyContent: 'space-between', flexWrap: 'wrap', gap: 16 }}>
        <div>
          <h1 style={{ fontSize: 26, fontWeight: 800 }}>Messages</h1>
          <p className="text-muted">{result?.total ?? 0} contact form submissions</p>
        </div>
        <div style={{ width: 180 }}>
          <NeoSelect value={status} onChange={(e) => handleStatusChange(e.target.value)}>
            <option value="">All statuses</option>
            <option value="new">New</option>
            <option value="resolved">Resolved</option>
          </NeoSelect>
        </div>
      </div>

      {error && <p className="text-danger">{error}</p>}

      <NeoCard style={{ padding: 0 }}>
        {loading && !result ? (
          <Spinner label="Loading messages…" />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ textAlign: 'left' }}>
                  {['From', 'Message', 'Received', 'Status', ''].map((h) => (
                    <th key={h} className="text-muted" style={{ padding: '16px 20px', fontSize: 13 }}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {result?.messages?.map((message) => (
                  <tr key={message.id} style={{ borderTop: '1px solid var(--shadow-dark)' }}>
                    <td style={{ padding: '14px 20px' }}>
                      <div style={{ fontWeight: 600 }}>{message.name}</div>
                      <div className="text-muted" style={{ fontSize: 13 }}>{message.email}</div>
                    </td>
                    <td style={{ padding: '14px 20px', maxWidth: 320 }}>
                      <span
                        className="text-muted"
                        style={{
                          display: 'block',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        {message.message}
                      </span>
                    </td>
                    <td style={{ padding: '14px 20px' }} className="text-muted">
                      {new Date(message.createdAt).toLocaleDateString()}
                    </td>
                    <td style={{ padding: '14px 20px' }}>
                      <NeoBadge variant={message.status === 'new' ? 'active' : ''}>
                        {message.status === 'new' ? 'New' : 'Resolved'}
                      </NeoBadge>
                    </td>
                    <td style={{ padding: '14px 20px' }}>
                      <div className="neo-row" style={{ gap: 8 }}>
                        <Link to={`/admin/messages/${message.id}`}>
                          <NeoButton size="sm">View</NeoButton>
                        </Link>
                        <NeoButton size="sm" disabled={updatingId === message.id} onClick={() => toggleResolved(message)}>
                          {message.status === 'new' ? 'Resolve' : 'Reopen'}
                        </NeoButton>
                      </div>
                    </td>
                  </tr>
                ))}
                {result && result.messages.length === 0 && (
                  <tr>
                    <td colSpan={5} style={{ padding: 32, textAlign: 'center' }} className="text-muted">
                      No messages found.
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
