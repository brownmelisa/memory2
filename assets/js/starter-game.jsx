import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel={channel} />, root);
}

// Client-Side state for the Memory game is:
// {
//   tiles: list of letters, string is empty if the letters should not be revealed
//   game_over: boolean value of whether game is over
// }

class Starter extends React.Component {

  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      tiles: [],
      game_over: false,
      num_clicks: 0,
      open_tiles: [],
    };

    this.channel
      .join()
      .receive("ok", this.got_view.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp); });

    this.channel.on("update", this.got_view.bind(this));
  }

  got_view(view) {
    console.log("new view", view);
    this.setState(view.game);
  }

  // newGameHandler - resets the tiles in game state when new game button is clicked

  // make sure to only check match for first 2 tiles open
  tile_click_handler(ev) {
    // if 2 tiles are open, check if they match
    let index = ev.target.attributes.index.value;
    if (this.state.open_tiles.length < 2) {
      this.channel.push("check_match",
                        { index1: index })
        .receive("ok", this.got_view.bind(this));
    }
  }

  render() {
    let tiles = _.map(this.state.tiles, (letter, index) => {
      return <TileItem
        key={index} tile={letter} indx = {index}
        tile_click={this.tile_click_handler.bind(this)} />;
    });

    return (
      <div className="container" id="mem-game">
        <h1>Memory Tiles</h1>
        <div className="row">
          <div className="col-8">
            <div className="grid-container">{tiles}</div>
          </div>

          <div className="col-4">
            <ScoreBox clicks={this.state.num_clicks} game_over={this.state.game_over}/>
          </div>
        </div>
        <a href="http://mochiswebforge.site">back to home page</a>
      </div>
    );
  }
}

function TileItem(props) {
  let {letter, indx, tile_click} = props;
  // text of tile is only displayed if the hide attribute is false
  return (
    <div className="grid-item">
      <button className="tile-btn"
              index={indx}
              onClick={tile_click}>
        <div className="btn-text">{letter}</div>
      </button>
    </div>
  );
}

function NewGameButton(props) {
  let {new_game} = props;
  return (
    <div>
      <button id="new-game-btn"
              onClick={new_game}>New Game
      </button>
    </div>
  );
}

function ScoreBox(props) {
  let {clicks, game_over} = props;
  return (
    <div id="score-box">
      <p>Clicks: {clicks}</p>
      {game_over ? <p>You win!</p> : null}
    </div>
  );
}
