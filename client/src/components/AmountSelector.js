import React, { useState } from 'react';

const AmountSelector = ({ onAmountSelect }) => {
  const predefinedAmounts = [1000, 5000, 10000]; // Amounts in cents
  const [customAmount, setCustomAmount] = useState('');

  const handlePredefinedAmountSelect = (amount) => {
    onAmountSelect(amount);
  };

  const handleCustomAmountChange = (e) => {
    setCustomAmount(e.target.value);
  };

  const handleCustomAmountSubmit = (e) => {
    e.preventDefault();
    const amountInCents = Math.round(parseFloat(customAmount) * 100);
    if (amountInCents > 0) {
      onAmountSelect(amountInCents);
      setCustomAmount('');
    } else {
      alert('Please enter a valid amount.');
    }
  };

  return (
    <div>
      <h3>Select Donation Amount</h3>
      <div>
        {predefinedAmounts.map((amount) => (
          <button key={amount} onClick={() => handlePredefinedAmountSelect(amount)}>
            ${amount / 100}
          </button>
        ))}
      </div>
      <form onSubmit={handleCustomAmountSubmit}>
        <input
          type="number"
          value={customAmount}
          onChange={handleCustomAmountChange}
          placeholder="Enter custom amount"
          min="0"
          step="0.01"
        />
        <button type="submit">Submit Custom Amount</button>
      </form>
    </div>
  );
};

export default AmountSelector;