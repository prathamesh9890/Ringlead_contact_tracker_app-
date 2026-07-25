export default function NeoToggle({ checked, onChange, disabled, label }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      className={`neo-toggle ${checked ? 'is-on' : ''}`}
      onClick={() => onChange?.(!checked)}
    >
      <span className="neo-toggle__knob" />
    </button>
  );
}
