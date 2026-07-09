import React from 'react';

const ReaderDisplay = ({ amount, status }) => {
  return (
    <div className="reader-display">
      <h2>Current Payment Amount</h2>
      <p>{amount ? `$${(amount / 100).toFixed(2)}` : 'No amount selected'}</p>
      <h3>Payment Status</h3>
      <p>{status || 'Awaiting payment...'}</p>
    </div>
  );
};

export default ReaderDisplay;