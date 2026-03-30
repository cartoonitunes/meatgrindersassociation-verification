contract token { 
    mapping (address => uint256) public balanceOf;  
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function mintToken(address target, uint256 mintedAmount);    
}

contract MeatCalculator {
    function calculateMeat(uint amountOfUnicorns) constant returns (uint amountOfMeat);
}

contract MeatGrindersAssociation {

    address public owner;

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    uint public rejectionMultiplier;
    Proposal[] public proposals;
    uint public numProposals;
    
    mapping (address => uint256) public unicornsKilled;
    uint public totalUnicornsKilled;

    token public unicornTokenAddress;
    token public meatTokenAddress;
    MeatCalculator public meatProvider;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, address sharesTokenAddress);

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint votingDeadline;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        bool inSupport;
        uint bribe;
        address voter;
    }

    modifier onlyShareholders {
        if (unicornTokenAddress.balanceOf(msg.sender) == 0) throw;
        _
    }

    function MeatGrindersAssociation(
        address unicornAddress, 
        address meatAddress, 
        uint minimumUnicornsToPassAVote, 
        uint minutesForDebate, 
        uint multiplierForVotesAgainst, 
        address meatCalculator
    ) {
        owner = msg.sender;
        if (minimumUnicornsToPassAVote == 0 ) minimumUnicornsToPassAVote = 1;
        changeVotingRules( unicornAddress,  meatAddress,  minimumUnicornsToPassAVote,  minutesForDebate,  multiplierForVotesAgainst); 
        changeMeatProvider(meatCalculator);
    }

    function changeVotingRules(address unicornAddress, address meatAddress, uint minimumSharesToPassAVote, uint minutesForDebate, uint multiplierForVotesAgainst) onlyOwner {
        unicornTokenAddress = token(unicornAddress);
        meatTokenAddress = token(meatAddress);
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        rejectionMultiplier = multiplierForVotesAgainst;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, unicornTokenAddress);
    }
    
    function changeMeatProvider(address newMeatProvider) {
        meatProvider = MeatCalculator(newMeatProvider);
    }

    function newProposal(address beneficiary, uint etherAmount, string JobDescription, bytes transactionBytecode) onlyShareholders returns (uint proposalID) {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = etherAmount;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, etherAmount, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
        numProposals = proposalID+1;
    }

    function checkProposalCode(uint proposalNumber, address beneficiary, uint etherAmount, bytes transactionBytecode) constant returns (bool codeChecksOut) {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
    }

    function vote(uint proposalNumber, bool supportsProposal) onlyShareholders returns (uint voteID){
        Proposal p = proposals[proposalNumber];
        if (p.voted[msg.sender] == true) throw;

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender, bribe: sqrt(msg.value + msg.gas*tx.gasprice)});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        Voted(proposalNumber,  supportsProposal, msg.sender);
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) returns (int result) {
        Proposal p = proposals[proposalNumber];
        if (now < p.votingDeadline  
            ||  p.executed        
            ||  p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode))
            throw;

        uint quorum = 0;
        uint yea = 0; 
        uint nay = 0;

        for (uint i = 0; i <  p.votes.length; ++i) {
            Vote v = p.votes[i];
            uint voteWeight = unicornTokenAddress.balanceOf(v.voter); 
            quorum += voteWeight * v.bribe;
            if (v.inSupport) {
                yea += voteWeight * v.bribe;
            } else {
                nay += voteWeight * v.bribe;
            }
        }

        if (quorum <= minimumQuorum) {
            throw;
        } else if (yea > nay ) {
            p.recipient.call.value(p.amount * 1 ether)(transactionBytecode);
            p.executed = true;
            p.proposalPassed = true;
        } else {
            p.executed = true;
            p.proposalPassed = false;
        } 
        ProposalTallied(proposalNumber, result, quorum, p.proposalPassed);
    }

    function receiveApproval(address _from, uint256 _value, address _token) {
        if(token(_token) != unicornTokenAddress) throw;
        if (!unicornTokenAddress.transferFrom(_from, address(this), _value)) throw;
        meatTokenAddress.mintToken(_from, meatProvider.calculateMeat(_value));
        unicornsKilled[_from] += _value;
        totalUnicornsKilled += _value;
    }    

    function sqrt(uint x) constant returns (uint y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }    

    function grindUnicorns(uint256 amountOfUnicornsToGrind) {
        unicornTokenAddress.transferFrom(msg.sender, address(this), amountOfUnicornsToGrind);
        meatTokenAddress.mintToken(msg.sender, meatProvider.calculateMeat(amountOfUnicornsToGrind));
        unicornsKilled[msg.sender] += amountOfUnicornsToGrind;
        totalUnicornsKilled += amountOfUnicornsToGrind;
    }
}
