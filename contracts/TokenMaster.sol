// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenMaster is ERC721 {
    address public owner;
    uint256 public totalOccasions;
    // number of nft exist
    uint256 totalSupply;

    struct Occasion {
        uint256 id;
        string name;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
    }
    // to store on the blockchain
    mapping(uint256 => Occasion) occasions;
    mapping(uint256 => mapping(address => bool)) public hasBought; // mapping for bought already / address -> the person who has buy already

    // 1st uint256 is the id id of occasion then 2nd uint256 is the id of seat belong to when one thing is connected to other thing nested mapping works
    mapping(uint256 => mapping(uint256 => address)) public seatTaken;

    mapping(uint256 => uint256[]) seatsTaken;

    modifier onlyOwner() {
        require(msg.sender == owner);

        // underscore corresponding to function body
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        // sender is the address of the calling function (constructor)
        owner = msg.sender;
    }

    function list(
        string memory _name,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) public onlyOwner {
        totalOccasions++;
        occasions[totalOccasions] = Occasion(
            totalOccasions,
            _name,
            _cost,
            _maxTickets,
            _maxTickets,
            _date,
            _time,
            _location
        );
    }

    // buying nft/mint functions -> to create a tickets

    function mint(uint256 _id, uint256 _seat) public payable {
        require(_id != 0); // require that _id is not 0 or less than total occasion..
        require(_id <= totalOccasions);
        require(msg.value >= occasions[_id].cost); // require that ETH sent is greater than cost ...
        require(seatTaken[_id][_seat] == address(0)); // require that the seat is not taken and the seat is exist
        require(_seat <= occasions[_id].maxTickets); // require

        // ticket availability when purchased
        occasions[_id].tickets -= 1;

        hasBought[_id][msg.sender] = true; // updating buying status

        seatTaken[_id][_seat] = msg.sender; //assigning seat
        seatsTaken[_id].push(_seat); // setting up array so that nobody can't buy the seat which is sold out in the future
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
    }

    function getOccasion(uint256 _id) public view returns (Occasion memory) {
        return occasions[_id];
    }

    function getSeatsTaken(uint256 _id) public view returns (uint256[] memory) {
        return seatsTaken[_id];
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
