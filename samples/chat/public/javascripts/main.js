function random(min, max) {
  return Math.floor(Math.random()*(max-min+1)+min);
}

var Chat = React.createClass({

  getInitialState: function () {
    return {
      message: '',
      messages: []
    };
  },

  componentDidMount: function () {
    var self = this;
    this.sendable = true;
    var server = new WebSocket("ws://" + location.hostname + ":" + location.port);
    var user = localStorage.getItem('user') || prompt("What is your name, sir?").replace(/\:|\@/g, "") + "@" + randomColor({luminosity: 'dark'}) + "@" + random(1000, 2000);
    localStorage.setItem('user', user);
    server.onmessage = function (event) {
      var messages = JSON.parse(event.data);
      self.setState({messages: messages});
      window.scrollTo(0, document.body.scrollHeight);
      self.refs.message.focus();
      new Beep(random(18000, 22050)).play(messages[messages.length - 1].split(":")[0].split('@')[2], 0.05, [Beep.utils.amplify(8000)]);
    };

    server.onopen = function () {
      server.send(user + ": joined the room.");
    };

    server.onclose = function () {
      server.send(user + ": left the room.");
    };

    this.server = server;
    this.user = user;
    this.refs.message.focus();
  },

  sendMessage: function () {
    if (!this.sendable) {
      return false;
    }
    var self = this;
    setTimeout(function () {
      self.sendable = true; 
    }, 100);
    this.server.send(this.user + ":" + this.refs.message.value);
    this.refs.message.value = '';
    this.sendable = false;
  },

  sendMessageWithEnter: function (e) {
    if (e.keyCode == 13) {
     this.sendMessage(); 
    }
  },

  render: function () {
    var messages = this.state.messages.map(function (message) {
      var parts = message.split(":");
      var user = parts[0].split("@");
      var color = user[1];
      var name = user[0];
      return React.createElement("li", null,
        React.createElement('span', {style: {color: color}}, name+": "),
        React.createElement('span', null, parts.slice(1).join(":").trim())
      );
    });

    return React.createElement("div", null,
      React.createElement("ul", null, messages),
      React.createElement("input", { autofocus: true, placeholder: "write your message!", type: "text", ref: "message", onKeyUp: this.sendMessageWithEnter }),
      React.createElement("button", { type: "button", onClick: this.sendMessage }, "Send")
    ); 
  }

});

ReactDOM.render(React.createElement(Chat, null), document.getElementById('chat'));
