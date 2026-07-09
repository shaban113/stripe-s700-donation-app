import React, { useState } from 'react';
import AmountSelector from './AmountSelector';
import { submitDonation } from '../services/api';
import PaymentStatus from './PaymentStatus';

const DonationForm = () => {
  const [customAmount, setCustomAmount] = useState('');
  const [selectedAmount, setSelectedAmount] = useState(null);
  const [paymentStatus, setPaymentStatus] = useState(null);
  const [error, setError] = useState(null);

  const handleAmountChange = (amount) => {
    setSelectedAmount(amount);
    setCustomAmount('');
  };

  const handleCustomAmountChange = (event) => {
    setCustomAmount(event.target.value);
    setSelectedAmount(null);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const amountToSubmit = selectedAmount || customAmount;

    if (!amountToSubmit || isNaN(amountToSubmit) || amountToSubmit <= 0) {
      setError('Please enter a valid donation amount.');
      return;
    }

    setError(null);
    setPaymentStatus('Processing...');

    try {
      const response = await submitDonation(amountToSubmit);
      if (response.success) {
        setPaymentStatus('Donation successful! Thank you for your support.');
      } else {
        setPaymentStatus('Donation failed. Please try again.');
      }
    } catch (err) {
      setPaymentStatus('An error occurred. Please try again.');
    }
  };

  return (
    <div>
      <img src="/assets/logo.png" alt="MIB Gala 2025 Logo" style={{ maxWidth: 180, marginBottom: 16 }} />
      <h1>🎯 MIB Gala 2025</h1>
      <form onSubmit={handleSubmit}>
        <AmountSelector onAmountSelect={handleAmountChange} />
        <div>
          <label>
            Custom Amount:
            <input
              type="number"
              min="1"
              step="0.01"
              value={customAmount}
              onChange={handleCustomAmountChange}
              placeholder="Custom Amount ($)"
            />
          </label>
        </div>
        <button type="submit">Donate</button>
      </form>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {paymentStatus && <PaymentStatus status={paymentStatus} />}
    </div>
  );
};

export default DonationForm;