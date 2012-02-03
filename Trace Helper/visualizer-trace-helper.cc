#include "visualizer-trace-helper.h"


using namespace ns3;

VisualizerTraceHelper::VisualizerTraceHelper (unsigned int simulationLengthInMilliseconds,
                         NodeContainer theNodeContainer, int theRoutingProtocol)
{
  simulationLength = simulationLengthInMilliseconds;
  nodeContainer = theNodeContainer;
  routingProtocol = theRoutingProtocol;
  outputTopologySet = false;
  outputVideoOverlay = false;
}


VisualizerTraceHelper::~VisualizerTraceHelper ()
{

}

void 
VisualizerTraceHelper::EnableVideoOverlayOutput()
{
	if (!outputStream.is_open()) {
		outputVideoOverlay = true;
	}
}


void 
VisualizerTraceHelper::EnableTopologySetOutput()
{
	if (!outputStream.is_open()) {
		outputTopologySet = true;
	}
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
 * @brief Add video source node
 */
void 
VisualizerTraceHelper::AddVideoSource(ns3::Ptr<const ns3::Node> node) 
{
 	if (outputVideoOverlay) {
 		uint32_t id = node->GetId();        
		
		// FORMAT: vs <id> 
		outputStream << "vs " << id << endl;		
 	}
}
	 
/**
 * @brief Add video source node
 */
void 
VisualizerTraceHelper::AddVideoDestination(ns3::Ptr<const ns3::Node> node) 
{
 	if (outputVideoOverlay) {
 		uint32_t id = node->GetId();      
		  
		// FORMAT: vd <id> 
		outputStream << "vd " << id << endl;
 	}
}


/**
 * @brief Log a simulation property
 */
void 
VisualizerTraceHelper::LogMobilityArea(double x1_area1, double x2_area1, double y1_area1, double y2_area1)
{
	// FORMAT: ma <x1_area1> <x2_area1> <y1_area1>	<y2_area1>
	outputStream << "ma " << x1_area1 <<  " " << x2_area1 << " " << y1_area1 << " " << y2_area1 << endl;
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
  unsigned int now = Simulator::Now ().GetMilliSeconds();
  
  sscanf(text.c_str(), "/NodeList/%i/", &nodeId); // Get its id
  
  outputStream << "rc "; // Line type: Route Changed
  outputStream << nodeId << " ";
  outputStream << now << " ";
  
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
		outputStream << destId << "," << nextId << "," << hops;
		index++;
  }
  
  outputStream << endl;
  
  if (routingProtocol == OLSR && outputTopologySet) {
	  
	  unsigned int expTime = outputTopologySetExpTime[nodeId];
	  if (now > expTime) { 
		  Ptr<olsr::RoutingProtocol> olsr_rt = DynamicCast<olsr::RoutingProtocol> (
		              nodeContainer.Get(nodeId)->GetObject<Ipv4> ()->GetRoutingProtocol()
		   );
	  
		  const OlsrState &m_state = olsr_rt->GetOlsrState();
		  const TopologySet &topology = m_state.GetTopologySet ();
	  
		  outputStream << "ts " << nodeId << " " << now;
		  index = 0;
		  unsigned int minTime;
		  for (TopologySet::const_iterator tuple = topology.begin (); tuple != topology.end(); tuple++) {
			  expTime = tuple->expirationTime.GetMilliSeconds();
			  if (index == 0) {
			  	minTime = expTime;
			  }
			  else if(expTime < minTime) {
				  minTime = expTime;
			  }
			  outputStream << " " << tuple->destAddr << " " << tuple->lastAddr << " " << tuple->sequenceNumber << " " << expTime;
			  index++;
		  }
	  	  outputTopologySetExpTime[nodeId] = minTime;
		  outputStream << endl;
	  }
  }
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
VisualizerTraceHelper::MacFail (std::string text, Mac48Address address)
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
VisualizerTraceHelper::DtsOverlayForwardMessage (std::string text,  Ptr<const Packet> packet, Ipv4Address destAddr)
{
	int nodeId;
	sscanf(text.c_str(), "/NodeList/%i/", &nodeId);
	
    // Write to file,
    // format: sf <node id> <time> <seqNum> <destAddr>
  	if (PacketHasSeqTsHeader(packet)) {
  	  	uint32_t seqNum = GetSeqTsSeqNum(packet);
		
    	outputStream << "sf "; // Line type: Buffer Enqueue
    	outputStream << nodeId << " " ;
    	outputStream << Simulator::Now ().GetMilliSeconds() << " ";
    	outputStream << seqNum << " ";
    	outputStream << destAddr<< " ";
    	outputStream << endl;
	}	
}

void
VisualizerTraceHelper::DtsOverlayInsertMessage (std::string text, Ptr<const Packet> packet)
{
	int nodeId;
	sscanf(text.c_str(), "/NodeList/%i/", &nodeId);
	
    // Write to file,
    // format: si <node id> <time> <seqNum>
  	if (PacketHasSeqTsHeader(packet)) {
		uint32_t seqNum = GetSeqTsSeqNum(packet);
		
    	outputStream << "si "; // Line type: Buffer Enqueue
    	outputStream << nodeId << " " ;
    	outputStream << Simulator::Now ().GetMilliSeconds() << " ";
		outputStream << seqNum;
		outputStream << endl;
	}
	
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

/**
 * @brief Get the seqNum from a packet that contains a SeqTsHeader
 */
uint32_t
VisualizerTraceHelper::GetSeqTsSeqNum (ns3::Ptr<const ns3::Packet> packet)
{
	uint32_t seqNum = 0;
	
	std::ostringstream stream;
	stream << *packet;
	string str =  stream.str();
	
	string needle = "seq=";
	size_t start  = str.find(needle);
	if (start != string::npos) {
		string ws = "time=";
		size_t end   = str.find(ws);
		
		start += 4;
		string value = str.substr (start, end - (start + 1));
		sscanf(value.c_str(), "%u", &seqNum);
		// std::cout << "GetSeqTsSeqNum "<< str << " got: " << seqNum << std::endl; 
	}
	
	return seqNum;
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
  // Connect sinks
  ConnectSinks();
	
  outputStream.open(filename.c_str(), filemode);
  
  // Write the length of the simulation
  outputStream << "s " << simulationLength << endl;
  
  // output routing protocol
  if (routingProtocol == OLSR) {
  	outputStream << "rp OLSR" << endl;
  }
  else if (routingProtocol == AODV) {
  	outputStream << "rp AODV" << endl;
  }
  
  
  if (outputTopologySet) {
  	outputTopologySetExpTime =  vector<unsigned int>(nodeContainer.GetN(), 0);
  }
  
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
  Config::Connect ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/RemoteStationManager/MacTxFinalDataFailed",
	  MakeCallback (&VisualizerTraceHelper::MacFail, this));
  if (outputVideoOverlay) { // Only connect if enabled
	Config::Connect ("/NodeList/*/ApplicationList/*/$ns3::DtsServer/SeqTsReceived",
	  MakeCallback (&VisualizerTraceHelper::SeqTsReceived, this));
  	Config::Connect ("/NodeList/*/ApplicationList/*/$ns3::DtsTraceClient/SeqTsSent",
	  MakeCallback (&VisualizerTraceHelper::SeqTsSent, this));
	
	Config::Connect("/NodeList/*/$ns3::DtsOverlay/ForwardMessage",
	  MakeCallback (&VisualizerTraceHelper::DtsOverlayForwardMessage, this));
	Config::Connect("/NodeList/*/$ns3::DtsOverlay/InsertMessage",
	  MakeCallback (&VisualizerTraceHelper::DtsOverlayInsertMessage, this));

	
  }
  
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