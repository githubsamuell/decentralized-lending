import React, { useState, useEffect } from 'react';
import { web3, contract } from './Web3';

const App = () =>
{
  const [account, setAccount] = useState("");
  const [loan, setLoan] = useState(null);

  useEffect(() =>
  {
    async function load()
    {
      const accounts = await web3.eth.requestAccounts();
      setAccount(accounts[0]);
    }
    load();
  }, []);

  const requestLoan = async (principal, collateral, interestRate) =>
  {
    await contract.methods.requestLoan(principal, collateral, interestRate).send({ from: account });
  };

  const repayLoan = async () =>
  {
    await contract.methods.repayLoan().send({ from: account });
  };

  const getLoan = async () =>
  {
    const loan = await contract.methods.loans(account).call();
    setLoan(loan);
  };

  useEffect(() =>
  {
    if (account)
    {
      getLoan();
    }
  }, [account]);

  return (
    <div>
      <h1>Decentralized Lending Platform</h1>
      {loan && loan.isActive ? (
        <div>
          <h2>Your Loan</h2>
          <p>Principal: {loan.principal}</p>
          <p>Collateral: {loan.collateral}</p>
          <p>Interest Rate: {loan.interestRate / 100}%</p>
          <button onClick={repayLoan}>Repay Loan</button>
        </div>
      ) : (
        <div>
          <h2>Request a Loan</h2>
          <form onSubmit={(e) =>
          {
            e.preventDefault();
            const principal = e.target.principal.value;
            const collateral = e.target.collateral.value;
            const interestRate = e.target.interestRate.value;
            requestLoan(principal, collateral, interestRate);
          }}>
            <input type="number" name="principal" placeholder="Principal" required />
            <input type="number" name="collateral" placeholder="Collateral" required />
            <input type="number" name="interestRate" placeholder="Interest Rate" required />
            <button type="submit">Request Loan</button>
          </form>
        </div>
      )}
    </div>
  );
};

export default App;
