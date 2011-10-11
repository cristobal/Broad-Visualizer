#include "visualizer-trace-helper.h"


using namespace ns3;

VisualizerTraceHelper::VisualizerTraceHelper (unsigned int simulationLengthInMilliseconds,
                         NodeContainer theNodeContainer)
{
  simulationLength = simulationLengthInMilliseconds;
  nodeContainer = theNodeContainer;

  ConnectSinks();
}


VisualizerTraceHelper::~VisualizerTraceHelper ()
{

}


void
VisualizerTraceHelper::CourseChanged (std::string context, Ptr<const MobilityModel> model)
{
  if (!outputStream.is_open())
    return;
  
  int nodeId;
  
  Vector position = model->GetPosition (); // Get the position of the node to trace
  Vector velocity = model->GetVelocity (); // Get the velocity vector of the node
  
  sscanf(context.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>
  
  outputStream << "cc "; // Line type: Course Changed
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << (int)position.x << " ";
  outputStream << (int)position.y << " ";
  outputStream << velocity.x << " ";
  outputStream << velocity.y;
  outputStream << endl;
}                                       

/**
 * @brief Log the properties and role for the nodes in a node container
 */
void 
VisualizerTraceHelper::LogNodeContainerProperties(const NodeContainer nodeContainer, std::string role)
{
	NodeContainer::Iterator it;
	// Iterate trough the nodes and log the node properties and role
	for (it = nodeContainer.Begin(); it != nodeContainer.End(); it++) {
		LogNodeProperties((*it), role);
	}
}

/**
 * @brief Output the node properties and role for the given node
 */
void
VisualizerTraceHelper::LogNodeProperties(Ptr<const Node> node, std::string role) 
{
	uint32_t id = node->GetId();         
	Ipv4Address ipv4Address = node->GetObject<Ipv4> ()->GetAddress(1, 0).GetLocal ();
	Mac48Address macAddress = DynamicCast<WifiNetDevice> (node->GetDevice (0))->GetMac()->GetAddress ();
	
	// FORMAT: np <id> <role> <ipv4address>	<macAddress>
	outputStream << "np " << id <<  " " << role << " " << ipv4Address << " " << macAddress << endl;
}

/**
 * @brief Sink that handles static positioned nodes
 */                     
void 
VisualizerTraceHelper::StaticPosition(Ptr<const Node> node, int x, int y) 
{
	StaticPosition (node->GetId(), x, y);
}                      

/**
 * @brief Sink that handles static positioned nodes (Added by Morten)
 */
void
VisualizerTraceHelper::StaticPosition(int nodeId, int x, int y)
{
  if (!outputStream.is_open())
    return;

  // FORMAT: cc <node id> <time> <pos_x> <pos_y> <vel_x> <vel_y>

   outputStream << "cc "; // Line type: Course Changed
   outputStream << nodeId << " ";
   outputStream << Simulator::Now ().GetMilliSeconds() << " ";
   outputStream << x << " ";
   outputStream << y << " ";
   outputStream << 0 << " ";
   outputStream << 0;
   outputStream << endl;
}

void
VisualizerTraceHelper::RouteChanged (std::string text, uint32_t size)
{
  if (!outputStream.is_open())
    return;

  int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  outputStream << "rc "; // Line type: Route Changed
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  
  std::vector<GenericRoutingTableEntry> table = nodeContainer.Get (nodeId)->GetObject<CrossLayerInterface> ()->GetGenericRoutingTable ();

  // Iterate through all entries in the table                      
	int destId;
	int nextId;            
	int hops;
	int index = 0;
	std::vector<GenericRoutingTableEntry>::iterator it;
  for (it = table.begin(); it != table.end(); it++)
  {               
		if (index > 0) {
			outputStream << ",";
		}                     
		destId = GetNodeIdForAddress(it->GetDestAddr ());
		nextId = GetNodeIdForAddress(it->GetNextAddr ());
		hops	 = it->GetDistance();
		if (destId == nextId) {
			nextId = -1; // there is no next id points to same node final destination.
		}
		outputStream << destId << "," << nextId << "," << hops;
		index++;
  }
  
  outputStream << endl;
}


void
VisualizerTraceHelper::MacTransmit (std::string text, Ptr<const Packet> originalPacket)
{
  int nodeId;
  WifiMacHeader macHeader;
  Ptr<Packet> packet;
  Mac48Address nextHopAddress;
	
  // Make a copy of the packet so that it can be modified
  packet = Ptr<Packet>(new Packet(*originalPacket));

  // Peek and remove the MAC header
  packet->RemoveHeader (macHeader);
  
  if (!macHeader.IsData()) {
    return;
  }

	// bool hasSeqTs = PacketHasSeqTsHeader (packet);
	// if (hasSeqTs) {
	// std::cout << "VisualizerTraceHelper::MacTransmit -> *packet >> " << *packet << std::endl;
	// SeqTsHeader seqTs;
	// packet->RemoveHeader (seqTs);
	// SeqTsHeader *seqTs = GetSeqTsHeader (packet);
	// std::cout << "VisualizerTraceHelper::MacTransmit -> *sequenceNumber >> " << *seqTs << " " << std::endl;
	// }

  nextHopAddress = macHeader.GetAddr1();
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
	  
  // Write to file,
  // format: mt <node id> <time> <packet_size> <next_hop_id>
  
  outputStream << "mt "; // Line type: Mac Transmission
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << packet->GetSize () << " ";
  outputStream << GetNodeIdForAddress(nextHopAddress);
  outputStream << endl;
}


void
VisualizerTraceHelper::MacReceive (std::string text, Ptr<const Packet> originalPacket)
{
  int nodeId;
  LlcSnapHeader llcSnapHeader;
  WifiMacHeader macHeader;
  Ptr<Packet> packet;
  Mac48Address lastHopAddress;
  Mac48Address realDestinationAddress;
  
  // Make a copy of the packet so that it can be modified
  packet = Ptr<Packet>(new Packet(*originalPacket));
  
  // Peek and remove the MAC header
  packet->RemoveHeader (macHeader);
  
  if (!macHeader.IsData())
    return;
  
  realDestinationAddress = macHeader.GetAddr1();
  
  // Read the MAC address of the last hop. We need to guess where it's stored
  switch (macHeader.GetType ())
  {
    case WIFI_MAC_MGT_DEAUTHENTICATION:
    case WIFI_MAC_MGT_ACTION:
    case WIFI_MAC_MGT_ACTION_NO_ACK:
      lastHopAddress = macHeader.GetAddr2();
      break;
    case WIFI_MAC_DATA:
      if (!macHeader.IsToDs() && !macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr2();
      }
      else if (!macHeader.IsToDs() && macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr3();
      }
      else if (macHeader.IsToDs() && !macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr2();
      }
      else if (macHeader.IsToDs() && macHeader.IsFromDs())
      {
        lastHopAddress = macHeader.GetAddr4();
      }
      else
      {
        NS_FATAL_ERROR ("Impossible ToDs and FromDs flags combination");
      }
      break;
    default:
      return;
  }
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: mr <node id> <time> <packet_size> <last_hop_id> <next_hop_id>
  
  outputStream << "mr "; // Line type: Mac Reception
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << packet->GetSize () << " ";
  outputStream << GetNodeIdForAddress(lastHopAddress) << " ";
  outputStream << GetNodeIdForAddress(realDestinationAddress);
  outputStream << endl;
}


void
VisualizerTraceHelper::MacDrop (std::string text, Ptr<const Packet> packet)
{
  int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: md <node id> <time>
  
  outputStream << "md "; // Line type: Mac Drop
  outputStream << nodeId << " ";
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << endl;
}


void
VisualizerTraceHelper::QueueChange (std::string text, int nPackets)
{
   int nodeId;
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  // Write to file,
  // format: be <node id> <time> <new_queue_size>
  
  outputStream << "be "; // Line type: Buffer Enqueue
  outputStream << nodeId << " " ;
  outputStream << Simulator::Now ().GetMilliSeconds() << " ";
  outputStream << nPackets;
  outputStream << endl;
}

void
VisualizerTraceHelper::SeqTsReceived(std::string text, Ptr<const Packet> packet, uint32_t sequenceNumber) 
{
	int nodeId;
	sscanf(text.c_str(), "/NodeList/%i/", &nodeId);
	
	// Write to file
	// format: sr <node id> <time> <sequence number>
	outputStream << "sr "; // Line type: Sequence Received
	outputStream << nodeId << " ";
	outputStream << Simulator::Now ().GetMilliSeconds() << " ";
	outputStream << sequenceNumber << " ";
	outputStream << endl;
	
}

void
VisualizerTraceHelper::SeqTsSent (std::string text, Ptr<const Packet> packet, uint32_t sequenceNumber)
{
	int nodeId;
	sscanf(text.c_str(), "/NodeList/%i/", &nodeId);
	
	// Write to file
	// format: ss <node id> <time> <sequence number>
	outputStream << "ss "; // Line type: Sequence Received
	outputStream << nodeId << " ";
	outputStream << Simulator::Now ().GetMilliSeconds() << " ";
	outputStream << sequenceNumber << " ";
	outputStream << endl;}

bool
VisualizerTraceHelper::PacketHasSeqTsHeader (Ptr<const Packet> packet) 
{
	bool found = false;
	
	std::stringstream ss;
	PacketContents (packet, ss);
	string str = ss.str();
	string needle = "SeqTsHeader";
	size_t pos = str.find(needle);
	
	if (pos != string::npos) {
		found = true;
	}
	
	return found;
}

SeqTsHeader*
VisualizerTraceHelper::GetSeqTsHeader (Ptr<const Packet> packet)
{
	SeqTsHeader *seqTs;
	PacketMetadata::ItemIterator i = packet->BeginItem();
	string name;
	string needle = "SeqTsHeader";
	size_t pos;
	while (i.HasNext()) {
		PacketMetadata::Item item = i.Next();
		if (!item.isFragment) {
			if (item.type == PacketMetadata::Item::HEADER) {
				name = item.tid.GetName ();
				pos = name.find(needle);
				if (pos != string::npos) {
					NS_ASSERT(item.tid.HasConstructor ());
					Callback<ObjectBase *> constructor = item.tid.GetConstructor();
					NS_ASSERT(!constructor.IsNull ());
					ObjectBase *instance = constructor();
					NS_ASSERT(instance != 0);
					Chunk *chunk = dynamic_cast<Chunk *>(instance);
					NS_ASSERT(seqTs != 0);
					chunk->Deserialize (item.current);
					seqTs = dynamic_cast<SeqTsHeader *>(chunk);
					break;
				}
			}
		}
	}
	return seqTs;
}

void 
VisualizerTraceHelper::PacketContents (Ptr<const Packet> packet, std::stringstream &ss)
{
	// From Packet->Print(os);
	PacketMetadata::ItemIterator i = packet->BeginItem();
	while (i.HasNext()) {
		PacketMetadata::Item item = i.Next();
		if (item.isFragment) {
			switch (item.type) {
				case PacketMetadata::Item::PAYLOAD:
					ss << "Payload";
					break;
				case PacketMetadata::Item::HEADER:
				case PacketMetadata::Item::TRAILER:
					ss << item.tid.GetName ();
					break;
			}
			ss << " Fragment [" << item.currentTrimedFromStart<<":"
		     << (item.currentTrimedFromStart + item.currentSize) << "]";
		}
		else {
			switch (item.type) {
	     case PacketMetadata::Item::PAYLOAD:
	      ss << "Payload (size=" << item.currentSize << ")";
	     	break;
	     case PacketMetadata::Item::HEADER:
	     case PacketMetadata::Item::TRAILER:
				ss << item.tid.GetName () << " (";
				/* chunk part */
				ss << ")";
				break;
			}
		}
	}
}

void
VisualizerTraceHelper::ManualTrace (std::string text)
{
  outputStream << text.c_str() << endl;
}

void
VisualizerTraceHelper::PeriodicBufferSizeUpdate ()
{
  int j = 0;
  for (NodeContainer::Iterator i = nodeContainer.Begin (); i != nodeContainer.End (); ++i)
  {
      outputStream << "be "; // Line type: Buffer Enqueue
      outputStream << j << " ";
      outputStream << Simulator::Now ().GetMilliSeconds() << " ";
      outputStream << (*i)->GetObject<ResourceManager> ()->GetQueuedPacketCount ();
      outputStream << endl;
      j++;
  }

  // Repeat each second..
  Simulator::Schedule (Seconds(1.0), &VisualizerTraceHelper::PeriodicBufferSizeUpdate, this);
}


void
VisualizerTraceHelper::StartWritingFile (std::string filename, std::ios::openmode filemode)
{
  outputStream.open(filename.c_str(), filemode);
  
  // Write the length of the simulation
  outputStream << "s " << simulationLength << endl;
}


void
VisualizerTraceHelper::EndWritingFile ()
{
  outputStream.close();
}


void
VisualizerTraceHelper::ConnectSinks()
{
  // Connect sources with sinks
  Config::Connect ("/NodeList/*/$ns3::MobilityModel/CourseChange",
    MakeCallback (&VisualizerTraceHelper::CourseChanged, this));
  Config::Connect("/NodeList/*/$ns3::olsr::RoutingProtocol/RoutingTableChanged",
    MakeCallback (&VisualizerTraceHelper::RouteChanged, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Phy/PhyTxBegin",
    MakeCallback (&VisualizerTraceHelper::MacTransmit, this));
  Config::Connect("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Phy/PhyRxEnd",
    MakeCallback (&VisualizerTraceHelper::MacReceive, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/$ns3::AdhocWifiMac/MacTxDrop",
    MakeCallback (&VisualizerTraceHelper::MacDrop, this));
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/$ns3::AdhocWifiMac/MacRxDrop",
    MakeCallback (&VisualizerTraceHelper::MacDrop, this));
  Config::Connect ("/NodeList/*/ApplicationList/*/$ns3::DtsOverlay/Enqueue",
    MakeCallback (&VisualizerTraceHelper::QueueChange, this));
	// Added by Cristobal
	Config::Connect ("/NodeList/*/ApplicationList/*/$ns3::DtsServer/SeqTsReceived",
		MakeCallback (&VisualizerTraceHelper::SeqTsReceived, this));
	Config::Connect ("/NodeList/*/ApplicationList/*/$ns3::DtsTraceClient/SeqTsSent",
		MakeCallback (&VisualizerTraceHelper::SeqTsSent, this));
  // Added by Morten.
  Simulator::Schedule (Seconds(1.0), &VisualizerTraceHelper::PeriodicBufferSizeUpdate,this);
}



// TODO Create a dictionary of address - nodeId
int
VisualizerTraceHelper::GetNodeIdForAddress(Ipv4Address address)
{
  NodeContainer::Iterator it;
  
  // Iterate through all nodes
  for (it = nodeContainer.Begin();
       it != nodeContainer.End();
       it++)
  {
    // Check if the addresses match
    Ipv4Address nodeAddr = (*it)->GetObject<Ipv4>()->GetAddress(1,0).GetLocal();
    if (address == nodeAddr)
      break;
  }
  
  // If there has been a match, we return the node's id
  if (it != nodeContainer.End())
  {
    return (*it)->GetId();
  }
  
  return -1;
}

int
VisualizerTraceHelper::GetNodeIdForAddress(Mac48Address address)
{
  NodeContainer::Iterator it;
  
  // Iterate through all nodes
  for (it = nodeContainer.Begin();
       it != nodeContainer.End();
       it++)
  {
    // Check if the addresses match
    Ptr<WifiNetDevice> netDevice = DynamicCast<WifiNetDevice> ((*it)->GetDevice(0));
    Mac48Address nodeAddr = netDevice->GetMac()->GetAddress();
    
    if (address == nodeAddr)
      break;
  }
  
  // If there has been a match, we return the node's id
  if (it != nodeContainer.End())
  {
    return (*it)->GetId();
  }
  
  return -1;
}    