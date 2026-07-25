export default function NeoCard({ children, className = '', inset = false, ...props }) {
  const classes = [inset ? 'neo-inset' : 'neo-raised', 'neo-card', className].filter(Boolean).join(' ');
  return (
    <div className={classes} {...props}>
      {children}
    </div>
  );
}
