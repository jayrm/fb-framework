#include once "fbfw-collections.bi"
#include once "../common/bi/person.bi"

/'
  Basic templating.
  
  Note that templating a collection twice has no effect. This is 
  necessary, because some collections depend on each other and may 
  template some types on their own.
  
  But besides that, there is no way of knowing if what we're trying to
  template was already templated by some other code who knows where.
  So, if the collection was already templated, the request is silently
  ignored without any side effect.
  
  Templating always take place inside the defined namespace, so if you
  template something within one, you'll have to either import the
  namespace or qualify as usual:
  
  namespace My
    template( aCollection, of( Something ) )
  end namespace
  
  var _
    anInstance => My.aCollection( of( Something ) )
'/
template( Array, of( Person ) )
template( Array, of( Person ) )
template( List, of( Person ) )
template( List, of( Person ) )
template( LinkedList, of( Person ) )
template( LinkedList, of( Person ) )
template( Dictionary, of( string ), of( Person ) )
template( Dictionary, of( string ), of( Person ) )
template( PriorityQueue, of( Person ) )
template( PriorityQueue, of( Person ) )

/'
  This is something you can't do. You can't template Arrays
  of collections because they don't have a default constructor,
  a copy constructor and an assignment operator accessible.
  
  Arrays are meant for types with the above characteristics and
  are usually faster that any of the other collections (if a bit
  more limited, though). Meant for standard types and POD structures.
'/
'template( Array, of( List( of( Person ) ) ) )
'template( Array, of( LinkedList( of( Person ) ) ) )
'template( Array, of( Dictionary( of( Person ) ) ) )
'template( Array, of( PriorityQueue( of( Person ) ) ) )

/'
  However, all of the other collections support nesting. You can
  thus template data structures as complex as you might need.
'/
template( List, _
  of( Array( of( Person ) ) ) )
template( List, _
  of( List( of( Person ) ) ) )
template( List, _
  of( LinkedList( of( Person ) ) ) )
template( List, _
  of( Dictionary( of( string ), of( Person ) ) ) )
template( List, _
  of( PriorityQueue( of( Person ) ) ) )

template( LinkedList, _
  of( Array( of( Person ) ) ) )
template( LinkedList, _
  of( List( of( Person ) ) ) )
template( LinkedList, _
  of( LinkedList( of( Person ) ) ) )
template( LinkedList, _
  of( Dictionary( of( string ), of( Person ) ) ) )
template( LinkedList, _
  of( PriorityQueue( of( Person ) ) ) )

template( Dictionary, _
  of( string ), of( Array( of( Person ) ) ) )
template( Dictionary, _
  of( string ), of( List( of( Person ) ) ) )
template( Dictionary, _
  of( string ), of( LinkedList( of( Person ) ) ) )
template( Dictionary, _
  of( string ), of( Dictionary( _
    of( string ), of( Person ) ) ) )
template( Dictionary, _
  of( string ), of( PriorityQueue( of( Person ) ) ) )

template( PriorityQueue, _
  of( Array( of( Person ) ) ) )
template( PriorityQueue, _
  of( List( of( Person ) ) ) )
template( PriorityQueue, _
  of( LinkedList( of( Person ) ) ) )
template( PriorityQueue, _
  of( Dictionary( of( string ), of( Person ) ) ) )
template( PriorityQueue, _
  of( PriorityQueue( of( Person ) ) ) )

/'
  All sort of data structures can be created this way. The only
  requisite is that the innermost collections are templated first,
  of course.
  
  This one templates a Dictionary, indexed by an integer, of priority
  queues of linked lists of Persons. 
'/
template( Dictionary, _
  of( integer ), _
  of( PriorityQueue( _
    of( LinkedList( of( Person ) ) ) ) ) )

/'
  And this is a usage example of such a compound collection
'/
var _
  aComplexCollection => Dictionary( _
    of( integer ), _
    of( PriorityQueue( _
      of( LinkedList( of( Person ) ) ) ) ) )()

/'
  The priority queues are straightforward to add to the dictionary:
  just new them up when you add them. This means the collection will
  take care of the lifetime of the object.
  
  The constructor for the queue sets its priority order to 'Descending'
  which is the default setting.
'/
aComplexCollection.add( _
  23434, _
  new PriorityQueue( _
    of( LinkedList( of( Person ) ) ) ) _
      ( Collections.PriorityOrder.Descending ) )

/'
  Adding the linked lists and the persons is not as straightforward,
  since you first need to create the linked lists and populate them
  _before_ adding them to the priority queue (since their order may
  change based on the priority we pass to the collection when we add
  them to the queue; thus, you can't reliably use the 'top' property
  of priority queues to access the last added item).
'/
var _
  aPriorityQueue => _
    aComplexCollection.find( 23434 ), _
  aLinkedList => _
    new LinkedList( of( Person ) )(), _
  anotherLinkedList => _
    new LinkedList( of( Person ) )()

aLinkedList->addLast( _
  new Person( "Paul", 37 ) )
aLinkedList->addLast( _
  new Person( "Mary", 24 ) )

anotherLinkedList->addLast( _
  new Person( "Joseph", 49 ) )
anotherLinkedList->addLast( _
  new Person( "Anne", 38 ) )

/'
  Just a little function to compute the average ages of the
  persons within a linked list.
'/
function _
  averageAgeOf( _
    byval aList as LinkedList( of( Person ) ) ptr ) _
  as integer
  
  if( aList->count = 0 ) then
    return( 0 )
  end if
  
  dim as integer _
    sum
  
  var _
    node => aList->first
  
  for _
    i as integer => 0 _
    to aList->count - 1
    
    sum +=> node->item->age
    
    node => node->forward
  next
  
  return( sum / aList->count )
end function

/'
  And we finally add the linked lists to the priority queue.
  Note the priority order here (older people gets top priority, as
  the default priority order for priority queues is 'Descending').
'/
aPriorityQueue->enqueue( _
  averageAgeOf( aLinkedList ), aLinkedList )
aPriorityQueue->enqueue( _
  averageAgeOf( anotherLinkedList ), anotherLinkedList )

/'
  And we can iterate the structure like this. Note the order in
  which the items are displayed on screen, and also that the
  __linked lists__ own the 'Person' classes we newed up into them.
'/
var _
  aQueue => aComplexCollection.find( 23434 )

? "Contents of the linked lists: "

for _
  i as integer => 0 _
  to aQueue->count - 1
  
  var _
    aList => aQueue->dequeue(), _
    aNode => aList->last
  
  ?
  ? "This list contains:"
  
  for _
    j as integer => 0 _
    to aList->count - 1
    
    ? *aNode->item
    
    aNode => aNode->backward
  next
  
  /'
    Note that dequeueing an item effectively removes it from the collection
    altogether BUT IT DOES NOT DESTROY IT. This is important because, otherwise,
    they would be useless. So, we need to dispose of them manually if we dequeue()
    them, but ONLY IF WE ADDED THE ITEM TO THE COLLECTION by pointer. If we added
    it by reference (meaning that the collection should not own the item), this is
    not necessary (and will in fact crash your app if you intend to do so).
    
    However, if they remain in the collection when it is destroyed, they will get
    automatically collected. This line effectively disposes of the persons we
    added to the linked list before.
  '/
  
  ?
  ? "Deleting linked list..."
  delete( aList )
next

sleep()
