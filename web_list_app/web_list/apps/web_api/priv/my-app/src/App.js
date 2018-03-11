import React, { Component } from 'react';
import logo from './logo.svg';
import {Socket} from 'phoenix';
import './App.css';

class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      socket: new Socket("ws://localhost:4000/socket", {}),
      ch: null
    }
    this.state.socket.connect();
    this.state.ch = this.state.socket.channel("room:lobby", {})
    this.state.ch.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
      </div>
    );
  }
}

export default App;
