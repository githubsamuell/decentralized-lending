import Web3 from 'web3';
import DecentralizedLending from './DecentralizedLending.json';

const web3 = new Web3(Web3.givenProvider || "http://localhost:7545");
const contractAddress = "0x5b29D567f6FC9c18692f8c9745b6aADa16a6Ed00"; // futuramente ira funcionar por input do usuario..
const contract = new web3.eth.Contract(DecentralizedLending.abi, contractAddress);

export { web3, contract };