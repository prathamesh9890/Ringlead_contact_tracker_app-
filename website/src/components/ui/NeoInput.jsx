export function NeoField({ label, children }) {
  return (
    <div className="neo-field">
      {label && <label>{label}</label>}
      {children}
    </div>
  );
}

export default function NeoInput({ className = '', ...props }) {
  return <input className={`neo-input ${className}`} {...props} />;
}

export function NeoSelect({ className = '', children, ...props }) {
  return (
    <select className={`neo-select ${className}`} {...props}>
      {children}
    </select>
  );
}
