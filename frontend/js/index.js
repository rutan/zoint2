const EventEmitter = require('events').EventEmitter;
const emitter = new EventEmitter();

function initCounter(el) {
    const counter = el;
    const valueElement = counter.find('.js-value');
    const od = new Odometer({
        el: valueElement[0],
        value: 0,
        duration: 25,
        format: '',
        theme: 'default'
    });

    let nowCount = counter.data('count');
    let oldCount = nowCount;
    od.update(nowCount);

    const updateCount = function () {
        if (nowCount !== oldCount) {
            oldCount = nowCount;
            od.update(nowCount);
        }
        setTimeout(updateCount, 2500);
    };
    updateCount();

    emitter.on('tweet', (data) => {
        nowCount = data.count;
    });
}

function displayTweets(el) {
    const layer = el;
    const shotTweet = (tweet) => {
        const el = $('<div class="tweets-item"></div>');
        const body = $('<div class="tweets-item-body"></div>');
        el.append($('<img>').attr('src', tweet.user['avatar_url']));
        body.append($('<div class="tweets-item-name"></div>').text(`@${tweet.user.name}`));
        body.append($('<div class="tweets-item-text"></div>').text(tweet.text));
        el.append(body);
        el.css('top', ($(window).height() - 50) * Math.random());
        el.on('animationend', (_e) => {
            el.remove();
        });
        layer.append(el);
    };

    const list = [];
    const watch = function () {
        const data = list.shift();
        if (data) shotTweet(data);
        setTimeout(watch, 500);
    };
    watch();

    emitter.on('tweet', (data) => {
        list.push(data.tweet);
    });
}

function connectWebSocket() {
    console.log('connect');
    const wsURL = `${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}`;
    let ws = new WebSocket(wsURL);
    const ping = () => {
        if (!ws) return;
        ws.send('ping');
        setTimeout(ping, 1000 * 5);
    };

    ws.onopen = function (e) {
        console.log(e);
        ping();
    };

    ws.onmessage = function (e) {
        const data = JSON.parse(e.data);
        console.log(data);
        emitter.emit(data.type || 'unknown', data);
    };

    ws.onclose = function (e) {
        ws = null;
        setTimeout(connectWebSocket, 1000);
    };

    ws.onerror = function (e) {
        console.error(e);
        ws.close();
    };
}

$(document).ready(function () {
    initCounter($('#js-zoi-counter'));
    displayTweets($('#js-tweets'));
    connectWebSocket();
});
