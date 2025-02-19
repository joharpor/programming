package actors

import akka.actor.{Props, ActorRef, Actor}
import utils.{StockQuote, FakeStockQuote}
import java.util.Random
import scala.collection.immutable.{HashSet, Queue}
import scala.collection.JavaConverters._
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global
import play.libs.Akka

/**
 * There is one StockActor per stock symbol.  The StockActor maintains a list of users watching the stock and the stock
 * values.  Each StockActor updates a rolling dataset of randomly generated stock values.
 */

class StockActor(symbol: String) extends Actor {

  // EP: a random stock quote generator, where "new = last ± 5%" .
  lazy val stockQuote: StockQuote = new FakeStockQuote

  // EP: these'll be the UserActors who subscribe to this StockActor
  protected[this] var watchers: HashSet[ActorRef] = HashSet.empty[ActorRef]

  // A random data set which uses stockQuote.newPrice to get each data point
  var stockHistory: Queue[java.lang.Double] = {

    /* EP:

     * create initial random Double, turn it into a Stream, create a "generator"
      (not sure Scala's term) based on it.

     * Never seen this before, but I understand it will appear in the scala class so I won't
       look into it now. I guess this is like a function with a "yield" in Python.

     */
    lazy val initialPrices: Stream[java.lang.Double] = (new Random().nextDouble * 800) #:: initialPrices.map(previous => stockQuote.newPrice(previous))
    // EP: force-generate 50, collect them into a scala.coll.imm.Queue.
    initialPrices.take(50).to[Queue]
  }

  // Fetch the latest stock value every 75ms
  // EP: note we never need to explicitly reference this thing again until we want to cancel it.
  val stockTick = context.system.scheduler.schedule(Duration.Zero, 75.millis, self, FetchLatest)

  def receive = {
    case FetchLatest =>
      // add a new stock price to the history and drop the oldest
      val newPrice = stockQuote.newPrice(stockHistory.last.doubleValue())
      stockHistory = stockHistory.drop(1) :+ newPrice
      // notify watchers
      watchers.foreach(_ ! StockUpdate(symbol, newPrice))
    case WatchStock(_) =>
      // send the stock history to the user
      // EP: We have access to the user here because the Controller sent a reference to the user instead
      // --- of a reference to itself as the "sender" on the `tell(msg, sender)` call.
      sender ! StockHistory(symbol, stockHistory.asJava)

      // add the watcher to the list
      /** EP:

        * He went with `watchers` being a "var immutable.HashSet[ActorRef]" so he's keeping an O(1)
          no-duplicates list of who wants to receive updates to this stock, where one can be assured
          that any particular instance of the list has not been altered since it was created.

        * I'm still unsure about the mechanics of retaining a list of ActorRefs.

       */
      watchers = watchers + sender
    case UnwatchStock(_) =>
      watchers = watchers - sender
      if (watchers.size == 0) {
        stockTick.cancel()
        context.stop(self)
      }
  }
}

/** EP:
  * This Actor is a broker between a UserActor (see UserActor.scala) who wants to start or stop
    receiving updates about some particular stock, and the StockActor (see above class) who has
    a directory of watching users, and watches a particular stock, and sends stock price updates
    to its subscribers.

  * NOTE: I believe the Sentiment Analysis piece only occurs through an $.ajax call sent whenever
     the user clicks on a stock graph. But on a regular (75ms) basis, they receive price updates
     to their graph (not sentiment values).
  */
class StocksActor extends Actor {
  def receive = {

    // EP: the '@' creates an "alias", i.e. we're naming the WatchStock(symbol) -> "watchStock"
    // --- so that we can refer to it as a variable in the code below
    case watchStock @ WatchStock(symbol) =>
      // get or create the StockActor for the symbol and forward this message

      /** EP:
       * `context` is an implicit val ActorSystem we inherit from Actor that enables us to
         reference whatever Actor we want by "name" given from "Akka.system.actorOf(class, name)"

       * Maybe this works better than keeping an instance variable Collection[ActorRef].

          TODO set a debug-point in order to see where the runtime's `child` function lives (Intellij: "no implementations found").
       */
      context.child(symbol).getOrElse {
        context.actorOf(Props(new StockActor(symbol)), symbol/*EP: name it for later retrieval*/)

        // pass the message along, but retain the original sender as the sender
      } forward watchStock

    /** EP: StockActors don't care what the 'symbol' in the UnwatchStock msg is bc they only refer
            to a single stock anyway. They will stop sending updates to whomever asks to Unwatch    */

    // EP: remove this user from the specified stock
    case unwatchStock @ UnwatchStock(Some(symbol)) =>
      // if there is a StockActor for the symbol forward this message
      context.child(symbol).foreach(_.forward(unwatchStock))

    // EP: remove this user from every stock
    case unwatchStock @ UnwatchStock(None) =>
      // if no symbol is specified, forward to everyone
      context.children.foreach(_.forward(unwatchStock))
  }
}

// EP: global singleton StocksActor actor; passes the messages to their respective StockActor actors.
// EP: TODO this is probably how I should be holding the reference to this actor in my multiplayer-game
object StocksActor {
  lazy val stocksActor: ActorRef = Akka.system.actorOf(Props(classOf[StocksActor]))
}


case object FetchLatest

case class StockUpdate(symbol: String, price: Number)

case class StockHistory(symbol: String, history: java.util.List[java.lang.Double])

case class WatchStock(symbol: String)

case class UnwatchStock(symbol: Option[String])
