import React, { Component } from 'react';
import logo from './logo.svg';
import {Socket} from 'phoenix';
import './App.css';

class App extends Component {

  socket = new Socket("ws://localhost:4000/socket", {});
  loobyCh = this.socket.channel("room:lobby", {})

  componentDidMount() {
    this.socket.connect();
    this.loobyCh.join()
      .receive("ok", resp => { console.log("Joined successfully to lobby ch", resp) })
      .receive("error", resp => { console.log("Unable to join lobby ch", resp) })
  }

  compnentWillUnmount() {
    this.lobbyCh.leave().receive("ok", () => alert("left lobby ch!") )
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
