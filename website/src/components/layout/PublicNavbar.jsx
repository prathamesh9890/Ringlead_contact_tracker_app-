import { NavLink } from 'react-router-dom';
import NeoButton from '../ui/NeoButton';

const links = [
  { to: '/', label: 'Home' },
  { to: '/pricing', label: 'Pricing' },
  { to: '/contact', label: 'Contact' },
];

export default function PublicNavbar() {
  return (
    <header style={{ padding: '20px 0' }}>
      <div className="container neo-row" style={{ justifyContent: 'space-between' }}>
        <NavLink to="/" style={{ fontSize: 24, fontWeight: 900 }}>
          <span className="float" style={{ marginRight: 6 }}>📞</span>
          Ring<span className="text-gradient">lead</span>
        </NavLink>

        <nav className="neo-row" style={{ gap: 28 }}>
          {links.map((link) => (
            <NavLink
              key={link.to}
              to={link.to}
              end={link.to === '/'}
              style={({ isActive }) => ({
                fontWeight: 600,
                color: isActive ? 'var(--accent)' : 'var(--text-secondary)',
              })}
            >
              {link.label}
            </NavLink>
          ))}
        </nav>

        <NeoButton as={NavLink} to="/admin/login" size="sm" variant="accent">
          Admin Login
        </NeoButton>
      </div>
    </header>
  );
}
