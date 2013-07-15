class Klient < AFHTTPClient
  def self.withBaseURL(url)
    client = Klient.clientWithBaseURL(NSURL.URLWithString(url))
    client
  end
end

class KittenModel
  attr_accessor :kittenKount
  def initialize(klient)
    @klient = klient
  end

  def kittens
    # make a sequence signal from a random number array of a given size
    strays = @kittenKount.times.map {rand(100)+100}.rac_sequence.signal

    # map that into a new signal of signals, one for each HTTP req, keeping the HTTP response body
    # flatten it to get the HTTP responses instead of the signal itself
    # make it replayLast so that anyone can get the results again when they subscribe
    strays.flattenMap! do |size|
      @klient.rac_getPath(size.to_s, parameters: nil).map! do |result_tuple|
        result_tuple.second
      end
    end.replayLast
  end
end

class KittenPresenter
  def initialize(model, view)
    # how many cats can we have?
    model.kittenKount = 4

    # wire up the signal from the model
    view.kittens = model.kittens

    # listen for events from the 'view'
    view.kittyKlicked.each do |catNum|
      puts catNum
    end
  end
end

class KittenCell < UICollectionViewCell
  REUSE_ID = 'kitten-cell'
  extend IB
  attr_accessor :image, :label

  outlet :image, UIImageView
  outlet :label, UILabel

  def kitty=(data)
    image.image = UIImage.imageWithData(data)
  end

  def label=(text)
    label.text = text
  end
end

class KittensViewController < UICollectionViewController
  attr_accessor :kittyKlicked, :kittens, :kittenCollectionView, :kittenCells
  extend IB

  outlet :kittenCollectionView, UICollectionView

  def kittyKlicked
    @kittyKlicked ||= RACCommand.command
    @kittyKlicked
  end

  def kittens=(signal)
    @kittens = signal
    kittens.each do |kittyImage|
      @kittenCells ||= []
      @kittenCells << {:image => kittyImage,
        :label => 'Cat'}
      @kittenCollectionView.reloadData
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    row = indexPath.indexAtPosition(1)
    rowData = @kittenCells[row]
    cellView = kittenCollectionView.dequeueReusableCellWithReuseIdentifier('kitten-cell', forIndexPath:indexPath)
    cellView.kitty = rowData[:image]
    cellView.label = rowData[:label]
    cellView
  end

  def collectionView(collectionView, numberOfItemsInSection: section)
    @kittenCells.nil? ? 0 : @kittenCells.size
  end

  def collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
    @kittyKlicked.execute indexPath.row
  end
end

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible
    @window.rootViewController = storyboard.instantiateInitialViewController
    buildSingletons
    true
  end

  def storyboard
    @storyboard ||= UIStoryboard.storyboardWithName 'Storyboard', bundle: NSBundle.mainBundle
  end

  def buildSingletons
    @kittenModel = KittenModel.new Klient.withBaseURL('http://placekitten.com')
    @kittensViewController = @window.rootViewController
    @kittenPresenter = KittenPresenter.new @kittenModel, @kittensViewController
  end

  def viewFromStoryBoard(name)
    vc = storyboard.instantiateViewControllerWithIdentifier name
    vc
  end
end
