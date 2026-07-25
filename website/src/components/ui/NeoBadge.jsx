export default function NeoBadge({ children, variant = '', className = '' }) {
  return <span className={`neo-badge ${variant && `neo-badge--${variant}`} ${className}`}>{children}</span>;
}
