import React from 'react';

const PaymentStatus = ({ status, message }) => {
  return (
    <div className={`payment-status ${status}`}>
      {status === 'success' ? (
        <h2>Payment Successful!</h2>
      ) : (
        <h2>Payment Failed</h2>
      )}
      <p>{message}</p>
    </div>
  );
};

export default PaymentStatus;