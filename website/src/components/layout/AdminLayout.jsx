import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import NeoButton from '../ui/NeoButton';

const links = [
  { to: '/admin/dashboard', label: 'Dashboard', icon: '📊' },
  { to: '/admin/users', label: 'Users', icon: '👥' },
  { to: '/admin/messages', label: 'Messages', icon: '✉️' },
];

export default function AdminLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  async function handleLogout() {
    await logout();
    navigate('/admin/login', { replace: true });
  }

  return (
    <div style={{ display: 'flex', minHeight: '100%' }}>
      <aside
        className="neo-flat"
        style={{
          width: 240,
          flexShrink: 0,
          padding: 24,
          display: 'flex',
          flexDirection: 'column',
          gap: 32,
        }}
      >
        <NavLink to="/" style={{ fontSize: 20, fontWeight: 800 }}>
          Ring<span style={{ color: 'var(--accent)' }}>lead</span>
          <div className="text-muted" style={{ fontSize: 12, fontWeight: 500 }}>
            Admin panel
          </div>
        </NavLink>

        <nav className="neo-stack" style={{ gap: 10 }}>
          {links.map((link) => (
            <NavLink key={link.to} to={link.to}>
              {({ isActive }) => (
                <div
                  className={isActive ? 'neo-inset' : ''}
                  style={{
                    padding: '12px 16px',
                    borderRadius: 'var(--radius-md)',
                    fontWeight: 600,
                    color: isActive ? 'var(--accent)' : 'var(--text-secondary)',
                    display: 'flex',
                    gap: 10,
                  }}
                >
                  <span>{link.icon}</span>
                  <span>{link.label}</span>
                </div>
              )}
            </NavLink>
          ))}
        </nav>

        <div className="neo-stack" style={{ marginTop: 'auto', gap: 12 }}>
          <div className="neo-inset" style={{ padding: 14, fontSize: 13 }}>
            <div style={{ fontWeight: 700 }}>{user?.businessName}</div>
            <div className="text-muted">{user?.email}</div>
          </div>
          <NeoButton size="sm" onClick={handleLogout}>
            Log out
          </NeoButton>
        </div>
      </aside>

      <main style={{ flex: 1, padding: '32px 40px', overflowX: 'auto' }}>
        <Outlet />
      </main>
    </div>
  );
}
