import React, { useState } from 'react';
import DonationForm from './components/DonationForm';
import AmountSelector from './components/AmountSelector';
import PaymentStatus from './components/PaymentStatus';
import ReaderDisplay from './components/ReaderDisplay';
import { createPaymentIntent } from './services/stripe';
import { submitDonation } from './services/api';

const App = () => {
  const [donationAmount, setDonationAmount] = useState(0);
  const [paymentStatus, setPaymentStatus] = useState(null);
  const [readerDisplay, setReaderDisplay] = useState({ amount: 0, status: '' });

  const handleDonationSubmit = async (amount) => {
    setDonationAmount(amount);
    setPaymentStatus(null);
    
    try {
      const paymentIntent = await createPaymentIntent(amount);
      setReaderDisplay({ amount, status: 'Processing payment...' });
      
      // Simulate payment processing
      const response = await submitDonation(paymentIntent.id);
      setPaymentStatus(response.success ? 'Payment successful!' : 'Payment failed.');
      setReaderDisplay({ amount, status: response.success ? 'Payment successful!' : 'Payment failed.' });
    } catch (error) {
      setPaymentStatus('Error processing payment.');
      setReaderDisplay({ amount, status: 'Error processing payment.' });
    }
  };

  return (
    <div>
      <h1>Fundraising Event</h1>
      <AmountSelector onSelectAmount={setDonationAmount} />
      <DonationForm onSubmit={handleDonationSubmit} />
      <PaymentStatus status={paymentStatus} />
      <ReaderDisplay amount={readerDisplay.amount} status={readerDisplay.status} />
    </div>
  );
};

export default App;