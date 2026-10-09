import { useEffect, useState } from 'react';
import api, { apiErrorMessage } from '../../api/client';
import NeoCard from '../../components/ui/NeoCard';
import NeoButton from '../../components/ui/NeoButton';
import Spinner from '../../components/ui/Spinner';

const LIMIT = 15;

const STATUSES = [
  { key: '', label: 'All' },
  { key: 'new', label: 'New' },
  { key: 'interested', label: 'Interested' },
  { key: 'followup', label: 'Follow-up' },
  { key: 'won', label: 'Won' },
  { key: 'lost', label: 'Lost' },
];

const STATUS_STYLE = {
  new: { color: '#2563eb', bg: '#dbeafe', label: 'New' },
  interested: { color: '#7c3aed', bg: '#ede9fe', label: 'Interested' },
  followup: { color: '#b45309', bg: '#fef3c7', label: 'Follow-up' },
  won: { color: '#059669', bg: '#d1fae5', label: 'Won' },
  lost: { color: '#dc2626', bg: '#fee2e2', label: 'Lost' },
  none: { color: '#6b7280', bg: '#f3f4f6', label: '—' },
};

export default function Leads() {
  const [status, setStatus] = useState('');
  const [page, setPage] = useState(1);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    api
      .get('/admin/leads', { params: { page, limit: LIMIT, status: status || undefined } })
      .then(({ data }) => {
        if (!cancelled) setResult(data.data);
      })
      .catch((err) => {
        if (!cancelled) setError(apiErrorMessage(err, 'Failed to load leads'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [page, status]);

  function pickStatus(key) {
    setStatus(key);
    setPage(1);
  }

  return (
    <div className="neo-stack" style={{ gap: 24 }}>
      <div>
        <h1 style={{ fontSize: 28, fontWeight: 900 }}>Leads</h1>
        <p className="text-muted">{result?.total ?? 0} tagged calls across all businesses</p>
      </div>

      <div className="neo-row" style={{ flexWrap: 'wrap', gap: 10 }}>
        {STATUSES.map((s) => (
          <NeoButton
            key={s.key || 'all'}
            size="sm"
            variant={status === s.key ? 'primary' : undefined}
            onClick={() => pickStatus(s.key)}
          >
            {s.label}
          </NeoButton>
        ))}
      </div>

      {error && <p className="text-danger">{error}</p>}

      <NeoCard style={{ padding: 0 }}>
        {loading && !result ? (
          <Spinner label="Loading leads…" />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ textAlign: 'left' }}>
                  {['Business', 'Contact', 'Status', 'Note', 'Updated'].map((h) => (
                    <th key={h} className="text-muted" style={{ padding: '16px 20px', fontSize: 13 }}>
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {result?.leads?.map((lead) => {
                  const st = STATUS_STYLE[lead.status] || STATUS_STYLE.none;
                  return (
                    <tr key={`${lead.business?.id}-${lead.callKey}`} style={{ borderTop: '1px solid var(--shadow-dark)' }}>
                      <td style={{ padding: '14px 20px', fontWeight: 700 }}>
                        {lead.business?.businessName || '—'}
                        <div className="text-muted" style={{ fontWeight: 400, fontSize: 12 }}>
                          {lead.business?.email}
                        </div>
                      </td>
                      <td style={{ padding: '14px 20px' }}>
                        {lead.name && lead.name !== lead.number ? lead.name : 'Unknown'}
                        <div className="text-muted" style={{ fontSize: 12 }}>{lead.number || '—'}</div>
                      </td>
                      <td style={{ padding: '14px 20px' }}>
                        <span
                          style={{
                            display: 'inline-block',
                            padding: '4px 12px',
                            borderRadius: 999,
                            fontSize: 12,
                            fontWeight: 800,
                            color: st.color,
                            background: st.bg,
                          }}
                        >
                          {st.label}
                        </span>
                      </td>
                      <td style={{ padding: '14px 20px', maxWidth: 320 }} className="text-muted">
                        {lead.note || '—'}
                      </td>
                      <td style={{ padding: '14px 20px' }} className="text-muted">
                        {new Date(lead.updatedAt).toLocaleDateString()}
                      </td>
                    </tr>
                  );
                })}
                {result && result.leads.length === 0 && (
                  <tr>
                    <td colSpan={5} style={{ padding: 32, textAlign: 'center' }} className="text-muted">
                      No leads yet. Businesses tag calls (Interested, Follow-up…) from the mobile app.
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
