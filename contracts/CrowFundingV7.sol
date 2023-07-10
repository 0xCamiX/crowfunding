// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract CrowFundingV7 {

    /* Arrays y mapping

        Un contrato inteligente pude almacenar cientos o miles de datos
        a lo largo de su vida útil. En estos casos debemos implementar estructuras
        de datos que nos permitan manipular gran cantidad de datos de manera eficiente.

        En Solidity tenemos 3 tipos de estructuras de datos:

        - Arrays
        - Mappings
        - Structs

        Arrays

        Los arrays son estructuras de datos que nos permiten almacenar una colección
        de datos del mismo tipo. En Solidity los arrays son de tamaño fijo y dinamico.

        1. longitud fija: uint[3] steps = [1, 2, 3];
        2. longitud dinamica: uint[] steps = [1, 2, 3];

        Métodos (solo funcionan para los arrays dinamicos)

        - push(): añade un elemento al final del array
        - pop(): elimina el último elemento del array

        Mappings

        Si tenemos un array con miles de datos, acceder a un valor en el medio
        de este puede ser costoso. Tener que recorrer todo el mismo para encontrar
        un valor requiere procesamiento y, por ende, consumo de gas. Los Mappings 
        solucionan este problema permitiendo asignar valores a una clave única para 
        acceder al dato.

        La declaración de un mapping requiere de especificar
        el tipo de dato de la clave, y el tipo de dato del valor que esta guardará.

        >> mapping(string => uint) public myMapping;
    */

    // crear la estructura de datos para los proyectos

    enum State { Ongoing, Failed, Succeeded, PaidOut }

    struct Project {
        string id;
        string name;
        string description;

        uint goal;
        uint amount;
        address payable owner;
        State state; // state of the project
    }

    struct Contribution {
        uint amount;
        address payable contributor;
    }

    Project[] public projects;

    // crear un mapping para almacenar las contribucciones.

    mapping(string => Contribution[]) public contributions;

    // modifiers

    modifier onlyOwner(uint _index) {
        require(msg.sender == projects[_index].owner, "Only owner can call this function");
        _;
    }

    modifier notOwner(uint _index) {
        require(msg.sender != projects[_index].owner, "Owner cannot call this function");
        _;
    }

    // Events

    event ProjectCreated(string id, string name, string description, uint goal, address owner);
    event ProjectContributed(string id, uint amount, address contributor);
    event ProjectPaidOut(string id, uint amount, address owner);

    // Functions

    function createProject(string calldata id, string calldata name, string calldata description, uint goal) public  {
        require(goal > 0, "Goal must be greater than 0");
        Project memory project = Project(id, name, description, goal, 0, payable(msg.sender), State.Ongoing);
        projects.push(project);
        emit ProjectCreated(id, name, description, goal, msg.sender);
    }

    function fundProject(uint256 index) notOwner(index) public payable {
        Project memory project = projects[index];
        require(project.state == State.Ongoing, "Project is not ongoing");
        require(msg.value > 0, "You must send some ether");
        require(project.amount + msg.value <= project.goal, "You are sending too much money");
        require(project.amount <= project.goal, "Project goal has been reached");

        project.owner.transfer(msg.value);
        project.amount += msg.value;

        projects[index] = project;

        contributions[project.id].push(Contribution(msg.value, payable(msg.sender)));
        emit ProjectContributed(project.id, msg.value, msg.sender);
    }

    function changeProjectState(uint index, State newState) onlyOwner(index) public {
        Project memory project = projects[index];
        require(project.state != newState, "State must be different");
        require(newState == State.Ongoing || newState == State.PaidOut, "State must be 0 or 1");
        project.state = newState;
        projects[index] = project;
        emit ProjectPaidOut(project.id, project.amount, project.owner);
    }
}
